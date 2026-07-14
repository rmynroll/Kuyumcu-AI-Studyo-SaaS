import sys
import os
import argparse
import json
import requests
import numpy as np
from PIL import Image, ImageEnhance, ImageFilter
from io import BytesIO
from skimage.color import rgb2lab, lab2rgb

def download_image(url_or_path):
    if url_or_path.startswith(('http://', 'https://')):
        response = requests.get(url_or_path, timeout=30)
        response.raise_for_status()
        return Image.open(BytesIO(response.content))
    else:
        return Image.open(url_or_path)

def main():
    parser = argparse.ArgumentParser(description="Kuyumcu AI Stüdyo - Jewelry Positioning Tool with Harmonization")
    parser.add_argument("--background", required=True, help="Background image path or URL")
    parser.add_argument("--jewelry", required=True, help="Clean transparent jewelry PNG path or URL")
    parser.add_argument("--output", required=True, help="Output image file path")
    parser.add_argument("--x", type=int, required=True, help="Anchor X coordinate")
    parser.add_argument("--y", type=int, required=True, help="Anchor Y coordinate")
    parser.add_argument("--scale", type=float, default=1.0, help="Scale multiplier for jewelry")
    parser.add_argument("--rotation", type=float, default=0.0, help="Rotation angle in degrees (clockwise)")
    parser.add_argument("--skew", type=float, default=0.0, help="Perspective skew factor (unused/placeholder)")
    
    # Harmonization arguments
    parser.add_argument("--color-match", action="store_true", default=True, help="Enable LAB color matching")
    parser.add_argument("--no-color-match", dest="color_match", action="store_false", help="Disable LAB color matching")
    parser.add_argument("--shadow", action="store_true", default=True, help="Enable contact shadow")
    parser.add_argument("--no-shadow", dest="shadow", action="store_false", help="Disable contact shadow")
    parser.add_argument("--shadow-opacity", type=float, default=0.3, help="Shadow opacity (0.0 to 1.0)")
    parser.add_argument("--shadow-blur", type=float, default=8.0, help="Shadow blur radius")
    parser.add_argument("--shadow-offset-x", type=int, default=-2, help="Shadow X offset")
    parser.add_argument("--shadow-offset-y", type=int, default=5, help="Shadow Y offset")
    parser.add_argument("--brightness-balance", action="store_true", default=True, help="Enable automatic brightness balancing")
    parser.add_argument("--no-brightness-balance", dest="brightness_balance", action="store_false", help="Disable automatic brightness balancing")
    
    args = parser.parse_args()
    
    result = {"success": False, "error": ""}
    
    try:
        # 1. Load images
        bg_img = download_image(args.background)
        j_img = download_image(args.jewelry)
        
        # Ensure RGBA for transparency handling
        if bg_img.mode != "RGBA":
            bg_img = bg_img.convert("RGBA")
        if j_img.mode != "RGBA":
            j_img = j_img.convert("RGBA")
            
        bg_w, bg_h = bg_img.size
        
        # 2. Extract background neighborhood statistics
        crop_x1 = max(0, args.x - 100)
        crop_y1 = max(0, args.y - 100)
        crop_x2 = min(bg_w, args.x + 100)
        crop_y2 = min(bg_h, args.y + 100)
        
        bg_crop = bg_img.crop((crop_x1, crop_y1, crop_x2, crop_y2)).convert("RGB")
        bg_arr = np.array(bg_crop) / 255.0
        bg_lab = rgb2lab(bg_arr)
        
        mean_bg = np.mean(bg_lab, axis=(0, 1))
        std_bg = np.std(bg_lab, axis=(0, 1))
        
        # 3. Apply brightness balancing
        if args.brightness_balance:
            bg_brightness = mean_bg[0] # L channel mean (0-100)
            if bg_brightness < 50.0:
                # Dim the jewelry up to 15% in dark backgrounds
                reduction = 1.0 - (0.15 * (50.0 - bg_brightness) / 50.0)
                enhancer = ImageEnhance.Brightness(j_img)
                j_img = enhancer.enhance(reduction)
                
        # 4. Apply LAB color matching (transfer style)
        if args.color_match:
            j_arr = np.array(j_img.convert("RGB")) / 255.0
            j_lab = rgb2lab(j_arr)
            j_alpha = np.array(j_img.split()[-1]) / 255.0
            
            mask_pixels = j_alpha > 0.05
            if np.sum(mask_pixels) > 0:
                mean_j = np.mean(j_lab[mask_pixels], axis=0)
                std_j = np.std(j_lab[mask_pixels], axis=0)
                std_j = np.clip(std_j, 1e-5, None)
                
                j_lab_trans = np.zeros_like(j_lab)
                for c in range(3):
                    j_lab_trans[..., c] = (j_lab[..., c] - mean_j[c]) * (std_bg[c] / std_j[c]) + mean_bg[c]
                    
                j_rgb_trans = lab2rgb(j_lab_trans)
                
                # Blend 25% to pull temperature slightly without destroying metal identity
                blend_factor = 0.25
                j_rgb_final = (1.0 - blend_factor) * j_arr + blend_factor * j_rgb_trans
                j_rgb_final = np.clip(j_rgb_final * 255.0, 0, 255).astype(np.uint8)
                
                j_img_trans = Image.fromarray(j_rgb_final, mode="RGB")
                j_img_trans.putalpha(j_img.split()[-1])
                j_img = j_img_trans
                
        # 5. Resize and rotate jewelry
        if args.scale != 1.0:
            new_w = max(1, int(j_img.width * args.scale))
            new_h = max(1, int(j_img.height * args.scale))
            j_img = j_img.resize((new_w, new_h), Image.Resampling.LANCZOS)
            
        if args.rotation != 0.0:
            j_img = j_img.rotate(-args.rotation, expand=True, resample=Image.Resampling.BICUBIC)
            
        # 6. Calculate placement coordinates
        paste_x = int(args.x - j_img.width / 2)
        paste_y = int(args.y - j_img.height / 2)
        
        # 7. Apply contact shadow
        if args.shadow:
            shadow_mask = j_img.split()[-1]
            shadow_img = Image.new("RGBA", j_img.size, (0, 0, 0, 255))
            shadow_img.putalpha(shadow_mask)
            
            # Apply Gaussian blur for softness
            if args.shadow_blur > 0:
                shadow_img = shadow_img.filter(ImageFilter.GaussianBlur(radius=args.shadow_blur))
                
            # Apply opacity scaling
            shadow_alpha = np.array(shadow_img.split()[-1])
            shadow_alpha = (shadow_alpha * args.shadow_opacity).astype(np.uint8)
            shadow_img.putalpha(Image.fromarray(shadow_alpha))
            
            # Paste shadow shifted slightly
            bg_img.paste(shadow_img, (paste_x + args.shadow_offset_x, paste_y + args.shadow_offset_y), mask=shadow_img.split()[-1])
            
        # 8. Paste jewelry
        bg_img.paste(j_img, (paste_x, paste_y), mask=j_img.split()[-1])
        
        # 9. Save output
        os.makedirs(os.path.dirname(os.path.abspath(args.output)), exist_ok=True)
        output_ext = os.path.splitext(args.output)[1].lower()
        if output_ext in ['.jpg', '.jpeg']:
            bg_img = bg_img.convert("RGB")
            bg_img.save(args.output, format="JPEG", quality=95)
        else:
            bg_img.save(args.output, format="PNG")
            
        result["success"] = True
        result["output_path"] = args.output
        result["x"] = args.x
        result["y"] = args.y
        result["scale"] = args.scale
        result["rotation"] = args.rotation
        result["color_matched"] = args.color_match
        result["shadow_applied"] = args.shadow
        result["brightness_balanced"] = args.brightness_balance
        
    except Exception as e:
        result["error"] = str(e)
        
    print(json.dumps(result))
    if not result["success"]:
        sys.exit(1)

if __name__ == "__main__":
    main()
