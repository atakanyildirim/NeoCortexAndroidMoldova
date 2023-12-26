class ImageDB {
  int? _id;
  String? _name;
  String? _version;
  String? _fullName;

  ImageDB(this._name, this._version, this._fullName);
  ImageDB.withId(this._id, this._name, this._version, this._fullName);

  int? get id => _id;
  String? get name => _name;
  String? get version => _version;
  String? get fullName => _fullName;

  set name(String? newName) {
    if (newName!.length <= 255) {
      _name = newName;
    }
  }

  set version(String? newV) {
    if (newV!.length <= 255) {
      _version = newV;
    }
  }

  set fullName(String? newV) {
    if (newV!.length <= 255) {
      _fullName = newV;
    }
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map["name"] = _name;
    map["version"] = _version;
    map["fullName"] = _fullName;

    if (_id != null) {
      map["id"] = _id;
    }
    return map;
  }

  ImageDB.fromObject(dynamic o) {
    _id = o["id"];
    _name = o["name"];
    _version = o["version"];
    _fullName = o["fullName"];
  }
}
