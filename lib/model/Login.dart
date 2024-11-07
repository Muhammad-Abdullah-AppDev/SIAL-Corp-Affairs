class Login {
  int _FOLNO;
  String _SHNAME;
  String _CNIC;
  String _EMAIL_ID;

  Login(this._FOLNO, this._SHNAME, this._CNIC, this._EMAIL_ID);

  int get FOLNO => _FOLNO;
  String get SHNAME => _SHNAME;
  String get CNIC => _CNIC;
  String get EMAIL_ID => _EMAIL_ID;

  // set FOLNO(int newFOLNO) {
  //   _FOLNO = newFOLNO;
  // }

  // set SHNAME(String newSHNAME) {
  //   _SHNAME = newSHNAME;
  // }

  // set CNIC(String newCNIC) {
  //   _CNIC = newCNIC;
  // }

  // set EMAIL_ID(String newEMAIL_ID) {
  //   _EMAIL_ID = newEMAIL_ID;
  // }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map["FOLNO"] = _FOLNO;
    map["SHNAME"] = _SHNAME;
    map["CNIC"] = _CNIC;
    map["EMAIL_ID"] = _EMAIL_ID;

    return map;
  }

  // Login.fromObject(dynamic o) {
  //   this._FOLNO = o["FOLNO"];
  //   this._SHNAME = o["SHNAME"];
  //   this._CNIC = o["CNIC"];
  //   this._EMAIL_ID = o["EMAIL_ID"];
  // }
}
