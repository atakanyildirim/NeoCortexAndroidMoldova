class Door {
  final Map<String, Section> sections;

  Door({required this.sections});

  factory Door.fromJson(Map<String, dynamic> json) {
    Map<String, Section> sections = {};
    json.forEach((key, value) {
      sections[key] = Section.fromJson(value);
    });
    return Door(sections: sections);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> sectionsJson = {};
    sections.forEach((key, value) {
      sectionsJson[key] = value.toJson();
    });
    return sectionsJson;
  }
}

class Section {
  final Map<String, Product> products;

  Section({required this.products});

  factory Section.fromJson(Map<String, dynamic> json) {
    Map<String, Product> products = {};
    json.forEach((key, value) {
      products[key] = Product.fromJson(value);
    });
    return Section(products: products);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> productsJson = {};
    products.forEach((key, value) {
      productsJson[key] = value.toJson();
    });
    return productsJson;
  }
}

class Product {
  final String name;
  final double? amount;

  Product({required this.name, required this.amount});

  factory Product.fromJson(Map<String, dynamic> json) {
    String name = json.keys.first;
    double? amount = double.tryParse(json[name].toString());
    return Product(name: name, amount: amount);
  }

  Map<String, dynamic> toJson() {
    return {name: amount};
  }
}
