// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Gallery _$GalleryFromJson(Map<String, dynamic> json) => Gallery(
      json['title'] as String,
      json['subtitle'] as String?,
      json['category'] as String?,
      json['cover'] as String?,
      json['uploader'] == null
          ? null
          : Uploader.fromJson(json['uploader'] as Map<String, dynamic>),
      json['visible'] as String?,
      json['language'] as String?,
      json['fileSize'] as String?,
      json['length'] as int,
      json['favcount'] as int?,
      (json['rating'] as num).toDouble(),
      (json['tags'] as List<dynamic>)
          .map((e) => Tags.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['coverSizeMode'] as String?,
      json['coverRowsMode'] as String?,
      json['currentPage'] as String,
      (json['pageList'] as List<dynamic>)
          .map((e) => GallerySubPages.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['wrapper'] as List<dynamic>)
          .map((e) => GalleryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['comment'] as List<dynamic>)
          .map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GalleryToJson(Gallery instance) => <String, dynamic>{
      'title': instance.title,
      'subtitle': instance.subtitle,
      'category': instance.category,
      'cover': instance.cover,
      'uploader': instance.uploader,
      'visible': instance.visible,
      'language': instance.language,
      'fileSize': instance.fileSize,
      'length': instance.length,
      'favcount': instance.favcount,
      'rating': instance.rating,
      'tags': instance.tags,
      'coverSizeMode': instance.coverSizeMode,
      'coverRowsMode': instance.coverRowsMode,
      'currentPage': instance.currentPage,
      'pageList': instance.pageList,
      'wrapper': instance.wrapper,
      'comment': instance.comment,
    };

Uploader _$UploaderFromJson(Map<String, dynamic> json) => Uploader(
      json['name'] as String,
      json['href'] as String,
    );

Map<String, dynamic> _$UploaderToJson(Uploader instance) => <String, dynamic>{
      'name': instance.name,
      'href': instance.href,
    };

Tags _$TagsFromJson(Map<String, dynamic> json) => Tags(
      json['raw'] as String,
      json['key'] as String,
    );

Map<String, dynamic> _$TagsToJson(Tags instance) => <String, dynamic>{
      'raw': instance.raw,
      'key': instance.key,
    };

GallerySubPages _$GallerySubPagesFromJson(Map<String, dynamic> json) =>
    GallerySubPages(
      json['number'] as int,
      json['href'] as String,
      json['current'] as bool,
    );

Map<String, dynamic> _$GallerySubPagesToJson(GallerySubPages instance) =>
    <String, dynamic>{
      'number': instance.number,
      'href': instance.href,
      'current': instance.current,
    };

GalleryItem _$GalleryItemFromJson(Map<String, dynamic> json) => GalleryItem(
      json['href'] as String,
      json['cover'] as String,
      json['title'] as String,
      json['alt'] as String,
    );

Map<String, dynamic> _$GalleryItemToJson(GalleryItem instance) =>
    <String, dynamic>{
      'href': instance.href,
      'cover': instance.cover,
      'title': instance.title,
      'alt': instance.alt,
    };

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
      unchanged(json['date'] as Object),
      json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      json['isUploader'] as bool?,
      json['content'] as String?,
    );

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
      'date': instance.date?.toIso8601String(),
      'user': instance.user,
      'isUploader': instance.isUploader,
      'content': instance.content,
    };

User _$UserFromJson(Map<String, dynamic> json) => User(
      json['name'] as String,
      json['href'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'name': instance.name,
      'href': instance.href,
    };

GalleryImage _$GalleryImageFromJson(Map<String, dynamic> json) => GalleryImage(
      json['title'] as String?,
      json['currentPage'] as int?,
      json['totalPage'] as int?,
      json['image'] as String,
      json['fileName'] as String?,
    );

Map<String, dynamic> _$GalleryImageToJson(GalleryImage instance) =>
    <String, dynamic>{
      'title': instance.title,
      'currentPage': instance.currentPage,
      'totalPage': instance.totalPage,
      'image': instance.image,
      'fileName': instance.fileName,
    };

GalleryList _$GalleryListFromJson(Map<String, dynamic> json) => GalleryList(
      json['endPage'] as int,
      json['count'] as int,
      json['currentPage'] as int?,
      json['displayMode'] == null
          ? null
          : DisplayMode.fromJson(json['displayMode'] as Map<String, dynamic>),
      (json['items'] as List<dynamic>)
          .map((e) => GalleryListItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GalleryListToJson(GalleryList instance) =>
    <String, dynamic>{
      'count': instance.count,
      'endPage': instance.endPage,
      'currentPage': instance.currentPage,
      'displayMode': instance.displayMode,
      'items': instance.items,
    };

DisplayMode _$DisplayModeFromJson(Map<String, dynamic> json) => DisplayMode(
      json['name'] as String,
      json['value'] as String,
    );

Map<String, dynamic> _$DisplayModeToJson(DisplayMode instance) =>
    <String, dynamic>{
      'name': instance.name,
      'value': instance.value,
    };

GalleryListItem _$GalleryListItemFromJson(Map<String, dynamic> json) =>
    GalleryListItem(
      json['category'] as String?,
      json['title'] as String,
      json['href'] as String,
      json['cover'] as String?,
      (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      json['uploader'] == null
          ? null
          : Uploader.fromJson(json['uploader'] as Map<String, dynamic>),
      json['pages'] as int?,
      json['date'] as String?,
    );

Map<String, dynamic> _$GalleryListItemToJson(GalleryListItem instance) =>
    <String, dynamic>{
      'category': instance.category,
      'title': instance.title,
      'href': instance.href,
      'cover': instance.cover,
      'tags': instance.tags,
      'uploader': instance.uploader,
      'pages': instance.pages,
      'date': instance.date,
    };
