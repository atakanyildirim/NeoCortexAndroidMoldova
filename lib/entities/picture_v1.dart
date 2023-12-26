class PictureV1 {
  int? _id;
  String? _customerCode;
  int? _imageType;
  String? _image;
  int? _orderNumber;
  String? _udate;
  int? _status;

  PictureV1(this._customerCode, this._imageType, this._image, this._orderNumber, this._udate, this._status);
  PictureV1.withId(
      this._id, this._customerCode, this._imageType, this._image, this._orderNumber, this._udate, this._status);

  int? get id => _id;
  String? get customerCode => _customerCode;
  int? get imageType => _imageType;
  String? get image => _image;
  int? get orderNumber => _orderNumber;
  String? get udate => _udate;
  int? get status => _status;

  set customerCode(String? value) {
    if (value!.length <= 255) {
      _customerCode = value;
    }
  }

  set imageType(int? value) {
    if (value! < 0) {
      _imageType = value;
    }
  }

  set image(String? value) {
    if (value!.length <= 255) {
      _image = value;
    }
  }

  set orderNumber(int? value) {
    if (value! < 0) {
      _orderNumber = value;
    }
  }

  set udate(String? value) {
    if (value!.length <= 255) {
      _udate = value;
    }
  }

  set status(int? value) {
    if (value! < 0) {
      _status = value;
    }
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map["customerCode"] = _customerCode;
    map["imageType"] = _imageType;
    map["image"] = _image;
    map["orderNumber"] = _orderNumber;
    map["udate"] = _udate;
    map["status"] = _status;

    if (_id != null) {
      map["id"] = _id;
    }
    return map;
  }

  PictureV1.fromObject(dynamic o) {
    _id = o["id"];
    _customerCode = o["customerCode"];
    _imageType = o["imageType"];
    _image = o["image"];
    _orderNumber = o["orderNumber"];
    _udate = o["udate"];
    _status = o["status"];
  }
}
