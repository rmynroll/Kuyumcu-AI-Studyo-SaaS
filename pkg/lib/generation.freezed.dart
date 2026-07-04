// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'generation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GenerationOutput _$GenerationOutputFromJson(Map<String, dynamic> json) {
  return _GenerationOutput.fromJson(json);
}

/// @nodoc
mixin _$GenerationOutput {
  @JsonKey(name: 'file_url')
  String get fileUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'thumbnail_url')
  String get thumbnailUrl => throw _privateConstructorUsedError;
  int? get width => throw _privateConstructorUsedError;
  int? get height => throw _privateConstructorUsedError;

  /// Serializes this GenerationOutput to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GenerationOutput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GenerationOutputCopyWith<GenerationOutput> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GenerationOutputCopyWith<$Res> {
  factory $GenerationOutputCopyWith(
          GenerationOutput value, $Res Function(GenerationOutput) then) =
      _$GenerationOutputCopyWithImpl<$Res, GenerationOutput>;
  @useResult
  $Res call(
      {@JsonKey(name: 'file_url') String fileUrl,
      @JsonKey(name: 'thumbnail_url') String thumbnailUrl,
      int? width,
      int? height});
}

/// @nodoc
class _$GenerationOutputCopyWithImpl<$Res, $Val extends GenerationOutput>
    implements $GenerationOutputCopyWith<$Res> {
  _$GenerationOutputCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GenerationOutput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fileUrl = null,
    Object? thumbnailUrl = null,
    Object? width = freezed,
    Object? height = freezed,
  }) {
    return _then(_value.copyWith(
      fileUrl: null == fileUrl
          ? _value.fileUrl
          : fileUrl // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: null == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String,
      width: freezed == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as int?,
      height: freezed == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GenerationOutputImplCopyWith<$Res>
    implements $GenerationOutputCopyWith<$Res> {
  factory _$$GenerationOutputImplCopyWith(_$GenerationOutputImpl value,
          $Res Function(_$GenerationOutputImpl) then) =
      __$$GenerationOutputImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'file_url') String fileUrl,
      @JsonKey(name: 'thumbnail_url') String thumbnailUrl,
      int? width,
      int? height});
}

/// @nodoc
class __$$GenerationOutputImplCopyWithImpl<$Res>
    extends _$GenerationOutputCopyWithImpl<$Res, _$GenerationOutputImpl>
    implements _$$GenerationOutputImplCopyWith<$Res> {
  __$$GenerationOutputImplCopyWithImpl(_$GenerationOutputImpl _value,
      $Res Function(_$GenerationOutputImpl) _then)
      : super(_value, _then);

  /// Create a copy of GenerationOutput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fileUrl = null,
    Object? thumbnailUrl = null,
    Object? width = freezed,
    Object? height = freezed,
  }) {
    return _then(_$GenerationOutputImpl(
      fileUrl: null == fileUrl
          ? _value.fileUrl
          : fileUrl // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: null == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String,
      width: freezed == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as int?,
      height: freezed == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GenerationOutputImpl implements _GenerationOutput {
  const _$GenerationOutputImpl(
      {@JsonKey(name: 'file_url') required this.fileUrl,
      @JsonKey(name: 'thumbnail_url') required this.thumbnailUrl,
      this.width,
      this.height});

  factory _$GenerationOutputImpl.fromJson(Map<String, dynamic> json) =>
      _$$GenerationOutputImplFromJson(json);

  @override
  @JsonKey(name: 'file_url')
  final String fileUrl;
  @override
  @JsonKey(name: 'thumbnail_url')
  final String thumbnailUrl;
  @override
  final int? width;
  @override
  final int? height;

  @override
  String toString() {
    return 'GenerationOutput(fileUrl: $fileUrl, thumbnailUrl: $thumbnailUrl, width: $width, height: $height)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GenerationOutputImpl &&
            (identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, fileUrl, thumbnailUrl, width, height);

  /// Create a copy of GenerationOutput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GenerationOutputImplCopyWith<_$GenerationOutputImpl> get copyWith =>
      __$$GenerationOutputImplCopyWithImpl<_$GenerationOutputImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GenerationOutputImplToJson(
      this,
    );
  }
}

abstract class _GenerationOutput implements GenerationOutput {
  const factory _GenerationOutput(
      {@JsonKey(name: 'file_url') required final String fileUrl,
      @JsonKey(name: 'thumbnail_url') required final String thumbnailUrl,
      final int? width,
      final int? height}) = _$GenerationOutputImpl;

  factory _GenerationOutput.fromJson(Map<String, dynamic> json) =
      _$GenerationOutputImpl.fromJson;

  @override
  @JsonKey(name: 'file_url')
  String get fileUrl;
  @override
  @JsonKey(name: 'thumbnail_url')
  String get thumbnailUrl;
  @override
  int? get width;
  @override
  int? get height;

  /// Create a copy of GenerationOutput
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GenerationOutputImplCopyWith<_$GenerationOutputImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Generation _$GenerationFromJson(Map<String, dynamic> json) {
  return _Generation.fromJson(json);
}

/// @nodoc
mixin _$Generation {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'company_id')
  String get companyId => throw _privateConstructorUsedError;
  @JsonKey(name: 'product_id')
  String? get productId => throw _privateConstructorUsedError;
  @JsonKey(name: 'generation_mode')
  String get generationMode =>
      throw _privateConstructorUsedError; // template | reference
  @JsonKey(name: 'generation_type')
  String get generationType =>
      throw _privateConstructorUsedError; // image | video
  GenerationStatus get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'error_message')
  String? get errorMessage => throw _privateConstructorUsedError;
  @JsonKey(name: 'output_urls')
  List<GenerationOutput> get outputUrls => throw _privateConstructorUsedError;
  @JsonKey(name: 'credit_cost')
  int get creditCost => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Generation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Generation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GenerationCopyWith<Generation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GenerationCopyWith<$Res> {
  factory $GenerationCopyWith(
          Generation value, $Res Function(Generation) then) =
      _$GenerationCopyWithImpl<$Res, Generation>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'company_id') String companyId,
      @JsonKey(name: 'product_id') String? productId,
      @JsonKey(name: 'generation_mode') String generationMode,
      @JsonKey(name: 'generation_type') String generationType,
      GenerationStatus status,
      @JsonKey(name: 'error_message') String? errorMessage,
      @JsonKey(name: 'output_urls') List<GenerationOutput> outputUrls,
      @JsonKey(name: 'credit_cost') int creditCost,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$GenerationCopyWithImpl<$Res, $Val extends Generation>
    implements $GenerationCopyWith<$Res> {
  _$GenerationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Generation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? productId = freezed,
    Object? generationMode = null,
    Object? generationType = null,
    Object? status = null,
    Object? errorMessage = freezed,
    Object? outputUrls = null,
    Object? creditCost = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      companyId: null == companyId
          ? _value.companyId
          : companyId // ignore: cast_nullable_to_non_nullable
              as String,
      productId: freezed == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String?,
      generationMode: null == generationMode
          ? _value.generationMode
          : generationMode // ignore: cast_nullable_to_non_nullable
              as String,
      generationType: null == generationType
          ? _value.generationType
          : generationType // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as GenerationStatus,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      outputUrls: null == outputUrls
          ? _value.outputUrls
          : outputUrls // ignore: cast_nullable_to_non_nullable
              as List<GenerationOutput>,
      creditCost: null == creditCost
          ? _value.creditCost
          : creditCost // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GenerationImplCopyWith<$Res>
    implements $GenerationCopyWith<$Res> {
  factory _$$GenerationImplCopyWith(
          _$GenerationImpl value, $Res Function(_$GenerationImpl) then) =
      __$$GenerationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'company_id') String companyId,
      @JsonKey(name: 'product_id') String? productId,
      @JsonKey(name: 'generation_mode') String generationMode,
      @JsonKey(name: 'generation_type') String generationType,
      GenerationStatus status,
      @JsonKey(name: 'error_message') String? errorMessage,
      @JsonKey(name: 'output_urls') List<GenerationOutput> outputUrls,
      @JsonKey(name: 'credit_cost') int creditCost,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$GenerationImplCopyWithImpl<$Res>
    extends _$GenerationCopyWithImpl<$Res, _$GenerationImpl>
    implements _$$GenerationImplCopyWith<$Res> {
  __$$GenerationImplCopyWithImpl(
      _$GenerationImpl _value, $Res Function(_$GenerationImpl) _then)
      : super(_value, _then);

  /// Create a copy of Generation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? productId = freezed,
    Object? generationMode = null,
    Object? generationType = null,
    Object? status = null,
    Object? errorMessage = freezed,
    Object? outputUrls = null,
    Object? creditCost = null,
    Object? createdAt = null,
  }) {
    return _then(_$GenerationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      companyId: null == companyId
          ? _value.companyId
          : companyId // ignore: cast_nullable_to_non_nullable
              as String,
      productId: freezed == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String?,
      generationMode: null == generationMode
          ? _value.generationMode
          : generationMode // ignore: cast_nullable_to_non_nullable
              as String,
      generationType: null == generationType
          ? _value.generationType
          : generationType // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as GenerationStatus,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      outputUrls: null == outputUrls
          ? _value._outputUrls
          : outputUrls // ignore: cast_nullable_to_non_nullable
              as List<GenerationOutput>,
      creditCost: null == creditCost
          ? _value.creditCost
          : creditCost // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GenerationImpl implements _Generation {
  const _$GenerationImpl(
      {required this.id,
      @JsonKey(name: 'company_id') required this.companyId,
      @JsonKey(name: 'product_id') this.productId,
      @JsonKey(name: 'generation_mode') required this.generationMode,
      @JsonKey(name: 'generation_type') required this.generationType,
      required this.status,
      @JsonKey(name: 'error_message') this.errorMessage,
      @JsonKey(name: 'output_urls')
      final List<GenerationOutput> outputUrls = const <GenerationOutput>[],
      @JsonKey(name: 'credit_cost') this.creditCost = 1,
      @JsonKey(name: 'created_at') required this.createdAt})
      : _outputUrls = outputUrls;

  factory _$GenerationImpl.fromJson(Map<String, dynamic> json) =>
      _$$GenerationImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'company_id')
  final String companyId;
  @override
  @JsonKey(name: 'product_id')
  final String? productId;
  @override
  @JsonKey(name: 'generation_mode')
  final String generationMode;
// template | reference
  @override
  @JsonKey(name: 'generation_type')
  final String generationType;
// image | video
  @override
  final GenerationStatus status;
  @override
  @JsonKey(name: 'error_message')
  final String? errorMessage;
  final List<GenerationOutput> _outputUrls;
  @override
  @JsonKey(name: 'output_urls')
  List<GenerationOutput> get outputUrls {
    if (_outputUrls is EqualUnmodifiableListView) return _outputUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_outputUrls);
  }

  @override
  @JsonKey(name: 'credit_cost')
  final int creditCost;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'Generation(id: $id, companyId: $companyId, productId: $productId, generationMode: $generationMode, generationType: $generationType, status: $status, errorMessage: $errorMessage, outputUrls: $outputUrls, creditCost: $creditCost, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GenerationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.companyId, companyId) ||
                other.companyId == companyId) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.generationMode, generationMode) ||
                other.generationMode == generationMode) &&
            (identical(other.generationType, generationType) ||
                other.generationType == generationType) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            const DeepCollectionEquality()
                .equals(other._outputUrls, _outputUrls) &&
            (identical(other.creditCost, creditCost) ||
                other.creditCost == creditCost) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      companyId,
      productId,
      generationMode,
      generationType,
      status,
      errorMessage,
      const DeepCollectionEquality().hash(_outputUrls),
      creditCost,
      createdAt);

  /// Create a copy of Generation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GenerationImplCopyWith<_$GenerationImpl> get copyWith =>
      __$$GenerationImplCopyWithImpl<_$GenerationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GenerationImplToJson(
      this,
    );
  }
}

abstract class _Generation implements Generation {
  const factory _Generation(
      {required final String id,
      @JsonKey(name: 'company_id') required final String companyId,
      @JsonKey(name: 'product_id') final String? productId,
      @JsonKey(name: 'generation_mode') required final String generationMode,
      @JsonKey(name: 'generation_type') required final String generationType,
      required final GenerationStatus status,
      @JsonKey(name: 'error_message') final String? errorMessage,
      @JsonKey(name: 'output_urls') final List<GenerationOutput> outputUrls,
      @JsonKey(name: 'credit_cost') final int creditCost,
      @JsonKey(name: 'created_at')
      required final DateTime createdAt}) = _$GenerationImpl;

  factory _Generation.fromJson(Map<String, dynamic> json) =
      _$GenerationImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'company_id')
  String get companyId;
  @override
  @JsonKey(name: 'product_id')
  String? get productId;
  @override
  @JsonKey(name: 'generation_mode')
  String get generationMode; // template | reference
  @override
  @JsonKey(name: 'generation_type')
  String get generationType; // image | video
  @override
  GenerationStatus get status;
  @override
  @JsonKey(name: 'error_message')
  String? get errorMessage;
  @override
  @JsonKey(name: 'output_urls')
  List<GenerationOutput> get outputUrls;
  @override
  @JsonKey(name: 'credit_cost')
  int get creditCost;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of Generation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GenerationImplCopyWith<_$GenerationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
