import 'package:json_annotation/json_annotation.dart';

part 'gallery.g.dart';

@JsonSerializable()
class Gallery extends Object {
  @override
  String toString() => "$title subPage: $currentPage";

  @JsonKey(name: 'title')
  String title;

  @JsonKey(name: 'subtitle')
  String? subtitle;

  @JsonKey(name: 'category')
  String? category;

  @JsonKey(name: 'cover')
  String? cover;

  @JsonKey(name: 'uploader')
  Uploader? uploader;

  @JsonKey(name: 'visible')
  String? visible;

  @JsonKey(name: 'language')
  String? language;

  @JsonKey(name: 'fileSize')
  String? fileSize;

  @JsonKey(name: 'length')
  int length;

  @JsonKey(name: 'favcount')
  int favcount;

  @JsonKey(name: 'rating')
  double rating;

  @JsonKey(name: 'tags')
  List<Tags> tags;

  @JsonKey(name: 'coverSizeMode')
  String? coverSizeMode;

  @JsonKey(name: 'coverRowsMode')
  String? coverRowsMode;

  @JsonKey(name: 'currentPage')
  String currentPage;

  @JsonKey(name: 'pageList')
  List<GallerySubPages> pageList;

  @JsonKey(name: 'wrapper')
  List<GalleryItem> wrapper;

  @JsonKey(name: 'comment')
  List<Comment> comment;

  Gallery(
    this.title,
    this.subtitle,
    this.category,
    this.cover,
    this.uploader,
    this.visible,
    this.language,
    this.fileSize,
    this.length,
    this.favcount,
    this.rating,
    this.tags,
    this.coverSizeMode,
    this.coverRowsMode,
    this.currentPage,
    this.pageList,
    this.wrapper,
    this.comment,
  );

  factory Gallery.fromJson(Map<String, dynamic> srcJson) =>
      _$GalleryFromJson(srcJson);

  Map<String, dynamic> toJson() => _$GalleryToJson(this);
}

@JsonSerializable()
class Uploader extends Object {
  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'href')
  String href;

  Uploader(this.name, this.href );

  factory Uploader.fromJson(Map<String, dynamic> srcJson) =>
      _$UploaderFromJson(srcJson);

  Map<String, dynamic> toJson() => _$UploaderToJson(this);
}

@JsonSerializable()
class Tags extends Object {
  @JsonKey(name: 'raw')
  String raw;

  @JsonKey(name: 'key')
  String key;

  Tags(
    this.raw,
    this.key,
  );

  factory Tags.fromJson(Map<String, dynamic> srcJson) =>
      _$TagsFromJson(srcJson);

  Map<String, dynamic> toJson() => _$TagsToJson(this);
}

@JsonSerializable()
class GallerySubPages extends Object {
  @JsonKey(name: 'number')
  int number;

  @JsonKey(name: 'href')
  String href;

  @JsonKey(name: 'current')
  bool current;

  GallerySubPages(
    this.number,
    this.href,
    this.current,
  );

  factory GallerySubPages.fromJson(Map<String, dynamic> srcJson) =>
      _$GallerySubPagesFromJson(srcJson);

  Map<String, dynamic> toJson() => _$GallerySubPagesToJson(this);
}

@JsonSerializable()
class GalleryItem extends Object {
  @JsonKey(name: 'href')
  String href;

  @JsonKey(name: 'cover')
  String cover;

  @JsonKey(name: 'title')
  String title;

  @JsonKey(name: 'alt')
  String alt;

  @override
  toString() => "$title $alt $cover $href";

  GalleryItem(
    this.href,
    this.cover,
    this.title,
    this.alt,
  );

  factory GalleryItem.fromJson(Map<String, dynamic> srcJson) =>
      _$GalleryItemFromJson(srcJson);

  Map<String, dynamic> toJson() => _$GalleryItemToJson(this);
}

unchanged(Object v) => v;

@JsonSerializable()
class Comment extends Object {
  @JsonKey(name: 'date', fromJson: unchanged)
  DateTime? date;

  @JsonKey(name: 'user')
  User? user;

  @JsonKey(name: 'isUploader')
  bool? isUploader;

  @JsonKey(name: 'content')
  String? content;

  Comment(
    this.date,
    this.user,
    this.isUploader,
    this.content,
  );

  factory Comment.fromJson(Map<String, dynamic> srcJson) =>
      _$CommentFromJson(srcJson);

  Map<String, dynamic> toJson() => _$CommentToJson(this);
}

@JsonSerializable()
class User extends Object {
  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'href')
  String href;

  User(
    this.name,
    this.href,
  );

  factory User.fromJson(Map<String, dynamic> srcJson) =>
      _$UserFromJson(srcJson);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class GalleryImage extends Object {
  @JsonKey(name: 'title')
  String? title;

  @JsonKey(name: 'currentPage')
  int? currentPage;

  @JsonKey(name: 'totalPage')
  int? totalPage;

  @JsonKey(name: 'image')
  String image;

  @JsonKey(name: 'fileName')
  String? fileName;

  GalleryImage(
    this.title,
    this.currentPage,
    this.totalPage,
    this.image,
    this.fileName,
  );

  @override
  toString() => "$currentPage / $totalPage $fileName : $image";

  factory GalleryImage.fromJson(Map<String, dynamic> srcJson) =>
      _$GalleryImageFromJson(srcJson);

  Map<String, dynamic> toJson() => _$GalleryImageToJson(this);
}

@JsonSerializable()
class GalleryList extends Object {

  @JsonKey(name: 'count')
  int count;

  @JsonKey(name: 'endPage')
  int endPage;

  @JsonKey(name: 'currentPage')
  int? currentPage;

  @JsonKey(name: 'displayMode')
  DisplayMode? displayMode;

  @JsonKey(name: 'items')
  List<GalleryListItem> items;

  GalleryList(
    this.endPage,
    this.count,
    this.currentPage,
    this.displayMode,
    this.items,
  );

  factory GalleryList.fromJson(Map<String, dynamic> srcJson) =>
      _$GalleryListFromJson(srcJson);

  Map<String, dynamic> toJson() => _$GalleryListToJson(this);
}

@JsonSerializable()
class DisplayMode extends Object {
  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'value')
  String value;

  DisplayMode(
    this.name,
    this.value,
  );

  factory DisplayMode.fromJson(Map<String, dynamic> srcJson) =>
      _$DisplayModeFromJson(srcJson);

  Map<String, dynamic> toJson() => _$DisplayModeToJson(this);
}

@JsonSerializable()
class GalleryListItem extends Object {
  @override
  String toString() => "\n$href : $title";

  @JsonKey(name: 'category')
  String? category;

  @JsonKey(name: 'title')
  String title;

  @JsonKey(name: 'href')
  String href;

  @JsonKey(name: 'cover')
  String? cover;

  @JsonKey(name: 'tags')
  List<String> tags;

  @JsonKey(name: 'uploader')
  Uploader? uploader;

  @JsonKey(name: 'pages')
  int? pages;

  @JsonKey(name: 'date')
  String? date;

  GalleryListItem(
    this.category,
    this.title,
    this.href,
    this.cover,
    this.tags,
    this.uploader,
    this.pages,
    this.date,
  );

  factory GalleryListItem.fromJson(Map<String, dynamic> srcJson) =>
      _$GalleryListItemFromJson(srcJson);

  Map<String, dynamic> toJson() => _$GalleryListItemToJson(this);
}
