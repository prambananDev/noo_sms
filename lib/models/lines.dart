class Lines {
  int? id;
  double? disc;
  String? fromDate;
  String? toDate;
  Lines({Lines? model});

  Map<String, dynamic> toJsonDisc() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['disc'] = disc;
    data['fromDate'] = fromDate;
    data['toDate'] = toDate;
    return data;
  }

  Map toJson() =>
      {'id': id, 'disc': disc, 'fromDate': fromDate, 'toDate': toDate};

  Lines.fromJson(Map json) {
    id = json['id'];
    disc = json['disc'];
    fromDate = json['fromDate'];
    toDate = json['toDate'];
  }
}
