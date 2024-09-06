import 'package:collection/collection.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:result_type/result_type.dart';
import 'package:get_it/get_it.dart';

abstract class AppwriteModel<T> {
  final String $id;
  final String $collectionId;
  final String $databaseId;
  final DateTime $createdAt;
  final DateTime $updatedAt;
  final List<String> $permissions;

  bool get canRead => $permissions.any((e) => e.contains("read"));
  bool get canUpdate => $permissions.any((e) => e.contains("update"));
  bool get canDelete => $permissions.any((e) => e.contains("delete"));

  bool get canReadUpdate => canRead && canUpdate;

  AppwriteModel({
    required this.$id,
    required this.$collectionId,
    required this.$databaseId,
    required this.$createdAt,
    required this.$updatedAt,
    required this.$permissions,
  });

  Map<String, dynamic> toJson();

  T copyWith({
    String? $id,
    String? $collectionId,
    String? $databaseId,
    DateTime? $createdAt,
    DateTime? $updatedAt,
    List<String>? $permissions,
  });

  @override
  String toString() {
    return toJson().toString();
  }

  Map<String, dynamic> toAppwrite();
}

class AppwriteClient {
  final Client client;
  late final Account account = Account(client);
  late final Databases databases = Databases(client);
  late final Realtime realtime = Realtime(client);
  late final Functions functions = Functions(client);
  late final Avatars avatars = Avatars(client);

  String? overrideDatabaseId;

  AppwriteClient(this.client);

  Future<Result<(int, List<T>), String>> page<T extends AppwriteModel<T>>(
      String databaseId,
      String collectionId,
      T Function(Document doc) fromAppwrite,
      {int limit = 25,
      int? offset,
      T? last}) async {
    assert(limit > 0);
    assert(offset != null && offset >= 0 || last != null);
    try {
      final response = await databases.listDocuments(
        databaseId: overrideDatabaseId ?? databaseId,
        collectionId: collectionId,
        queries: [
          Query.limit(limit),
          if (offset != null) Query.offset(offset),
          if (last != null) Query.cursorAfter(last.$id),
        ],
      );

      return Success((
        response.total,
        response.documents.map((e) => fromAppwrite(e)).toList()
      ));
    } on AppwriteException catch (e) {
      return Failure(e.message ?? "Unable to list documents");
    }
  }

  Future<Result<T, String>> get<T extends AppwriteModel<T>>(
      String databaseId, String collectionId, String documentId, T Function(Document doc) fromAppwrite) async {
    try {
      final response = await databases.getDocument(
        databaseId: overrideDatabaseId ?? databaseId,
        collectionId: collectionId,
        documentId: documentId,
      );

      return Success(fromAppwrite(response));
    } on AppwriteException catch (e) {
      return Failure(e.message ?? "Unable to get document");
    }
  }

  Future<Result<T, String>> create<T extends AppwriteModel<T>>(
      String databaseId, String collectionId, T Function(Document doc) fromAppwrite, T model) async {
    try {
      final response = await databases.createDocument(
        databaseId: overrideDatabaseId ?? databaseId,
        collectionId: collectionId,
        documentId: model.$id,
        data: model.toAppwrite(),
      );

      return Success(fromAppwrite(response));
    } on AppwriteException catch (e) {
      return Failure(e.message ?? "Unable to create document");
    }
  }

  Future<Result<T, String>> update<T extends AppwriteModel<T>>(
      String databaseId, String collectionId, T Function(Document doc) fromAppwrite, T model) async {
    try {
      final response = await databases.updateDocument(
        databaseId: overrideDatabaseId ?? databaseId,
        collectionId: collectionId,
        documentId: model.$id,
        data: model.toAppwrite(),
      );

      return Success(fromAppwrite(response));
    } on AppwriteException catch (e) {
      return Failure(e.message ?? "Unable to update document");
    }
  }

  Future<Result<void, String>> delete(String databaseId, String collectionId, String documentId) async {
    try {
      await databases.deleteDocument(
        databaseId: overrideDatabaseId ?? databaseId,
        collectionId: collectionId,
        documentId: documentId,
      );

      return Success(null);
    } on AppwriteException catch (e) {
      return Failure(e.message ?? "Unable to delete document");
    }
  }
}

class CollectionInfo {
  final String $id;
  final List<String> $permissions;
  final String databaseId;
  final String name;
  final bool enabled;
  final bool documentSecurity;

  const CollectionInfo({
    required this.$id,
    required this.$permissions,
    required this.databaseId,
    required this.name,
    required this.enabled,
    required this.documentSecurity,
  });
}

enum RelationshipType {
  oneToOne,
  oneToMany,
  manyToOne,
  manyToMany,
}

enum OnDelete {
  setNull,
  cascade,
  restrict,
}

enum Side {
  parent,
  child,
}

class Relationship {
  final bool required;
  final bool array;
  final String relatedCollection;
  final RelationshipType relationType;
  final bool twoWay;
  final String? twoWayKey;
  final OnDelete onDelete;
  final Side side;

  Relationship({
    this.required = false,
    this.array = false,
    required this.relatedCollection,
    required this.relationType,
    this.twoWay = false,
    this.twoWayKey,
    required this.onDelete,
    required this.side,
  });
}



class Customers extends AppwriteModel<Customers> {
  static const collectionInfo = CollectionInfo(
    $id: 'customers',
    $permissions: ['create("label:validProductKey")'],
    databaseId: 'dev',
    name: 'customers',
    enabled: true,
    documentSecurity: true,
  );

  final Relationship calendarEventsRelation = Relationship(
    required: false,
    array: false,
    relatedCollection: 'calendarEventParticipants',
    relationType: RelationshipType.manyToOne,
    twoWay: true,
    twoWayKey: 'customer',
    onDelete: OnDelete.setNull,
    side: Side.child,
  );
  final List<CalendarEventParticipants>? calendarEvents;
	final String? city;
	final String? email;
	final int id;
	final String name;
	final String? phone;
	final String? street;
	final String? zip;

  Customers._({
    this.calendarEvents,
		this.city,
		this.email,
		required this.id,
		required this.name,
		this.phone,
		this.street,
		this.zip,
    required super.$id,
    required super.$collectionId,
    required super.$databaseId,
    required super.$createdAt,
    required super.$updatedAt,
    required super.$permissions,
  })  : assert(city == null || city.isNotEmpty && city.length <= 64),
				assert(id >= -9223372036854775808),
				assert(id <= 9223372036854775807),
				assert(name.isNotEmpty),
				assert(name.length <= 128),
				assert(phone == null || phone.isNotEmpty && phone.length <= 64),
				assert(street == null || street.isNotEmpty && street.length <= 64),
				assert(zip == null || zip.isNotEmpty && zip.length <= 64);

  factory Customers({
    List<CalendarEventParticipants>? calendarEvents,
		String? city,
		String? email,
		required int id,
		required String name,
		String? phone,
		String? street,
		String? zip
  }) {
    return Customers._(
      calendarEvents: calendarEvents,
			city: city,
			email: email,
			id: id,
			name: name,
			phone: phone,
			street: street,
			zip: zip,
      $id: ID.unique(),
      $collectionId: collectionInfo.$id,
      $databaseId: collectionInfo.databaseId,
      $createdAt: DateTime.now().toUtc(),
      $updatedAt: DateTime.now().toUtc(),
      $permissions: collectionInfo.$permissions,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'calendarEvents': calendarEvents?.map((e) => e.toJson()).toList(),
			'city': city,
			'email': email,
			'id': id,
			'name': name,
			'phone': phone,
			'street': street,
			'zip': zip
    };
  }

  @override
  Map<String, dynamic> toAppwrite({bool isChild = false}) {
    return {
      'calendarEvents': calendarEvents?.map((e) => e.toAppwrite(isChild: true)).toList(),
			'city': city,
			'email': email,
			'id': id,
			'name': name,
			'phone': phone,
			'street': street,
			'zip': zip,
      if (!isChild) '\$id': $id,
    };
  }

  @override
  Customers copyWith({
    List<CalendarEventParticipants>? calendarEvents,
		String? city,
		String? email,
		int? id,
		String? name,
		String? phone,
		String? street,
		String? zip,
    String? $id,
    String? $collectionId,
    String? $databaseId,
    DateTime? $createdAt,
    DateTime? $updatedAt,
    List<String>? $permissions,
  }) {
    return Customers._(
      calendarEvents: calendarEvents ?? this.calendarEvents,
			city: city ?? this.city,
			email: email ?? this.email,
			id: id ?? this.id,
			name: name ?? this.name,
			phone: phone ?? this.phone,
			street: street ?? this.street,
			zip: zip ?? this.zip,
      $id: $id ?? this.$id,
      $collectionId: $collectionId ?? this.$collectionId,
      $databaseId: $databaseId ?? this.$databaseId,
      $createdAt: $createdAt ?? this.$createdAt,
      $updatedAt: $updatedAt ?? this.$updatedAt,
      $permissions: $permissions ?? this.$permissions,
    );
  }

  @override
  String toString() {
    return toJson().toString();
  }

  @override
  bool operator ==(Object other) {
		final eq = const ListEquality().equals;
    return other is Customers &&
      eq(calendarEvents, other.calendarEvents) &&
			city == other.city &&
			email == other.email &&
			id == other.id &&
			name == other.name &&
			phone == other.phone &&
			street == other.street &&
			zip == other.zip &&
      other.$id == $id;
  }

  @override
  int get hashCode {
    return Object.hashAllUnordered([
      ...(calendarEvents ?? []),
			city,
			email,
			id,
			name,
			phone,
			street,
			zip,
      $id,
    ]);
  }

  factory Customers.fromAppwrite(Document doc) {
    return Customers._(
      calendarEvents: List<CalendarEventParticipants>.unmodifiable(doc.data['calendarEvents'] == null ? [] : doc.data['calendarEvents'].map((e) => CalendarEventParticipants.fromAppwrite(Document.fromMap(e)))),
			city: doc.data['city'],
			email: doc.data['email'],
			id: doc.data['id'],
			name: doc.data['name'],
			phone: doc.data['phone'],
			street: doc.data['street'],
			zip: doc.data['zip'],
      $id: doc.$id,
      $collectionId: doc.$collectionId,
      $databaseId: doc.$databaseId,
      $createdAt: DateTime.parse(doc.$createdAt),
      $updatedAt: DateTime.parse(doc.$updatedAt),
      $permissions: List<String>.unmodifiable(doc.$permissions),
    );
  }

// API

  static AppwriteClient get client => GetIt.I.get<AppwriteClient>();
  static String get databaseId => GetIt.I.get<AppwriteClient>().overrideDatabaseId ?? collectionInfo.databaseId;

  static Future<Result<(int, List<Customers>), String>> page({
    int limit = 25,
    int? offset,
    Customers? last,
  }) async {
    return client.page<Customers>(
      collectionInfo.databaseId,
      collectionInfo.$id,
      Customers.fromAppwrite,
      limit: limit,
      offset: offset,
      last: last,
    );
  }

  static Future<Result<Customers, String>> get(String id) async {
    return client.get<Customers>(
      collectionInfo.databaseId,
      collectionInfo.$id,
      id,
      Customers.fromAppwrite,
    );
  }

  Future<Result<Customers, String>> create() async {
    return client.create<Customers>(
      collectionInfo.databaseId,
      collectionInfo.$id,
      Customers.fromAppwrite,
      this,
    );
  }

  Future<Result<Customers, String>> update() async {
    return client.update<Customers>(
      collectionInfo.databaseId,
      collectionInfo.$id,
      Customers.fromAppwrite,
      this,
    );
  }

  Future<Result<void, String>> delete() async {
    return client.delete(
      collectionInfo.databaseId,
      collectionInfo.$id,
      $id,
    );
  }
}



class Invoices extends AppwriteModel<Invoices> {
  static const collectionInfo = CollectionInfo(
    $id: 'invoices',
    $permissions: ['create("label:validProductKey")'],
    databaseId: 'dev',
    name: 'invoices',
    enabled: true,
    documentSecurity: true,
  );

  final int amount;
	final DateTime date;
	final String invoiceNumber;
	final String name;
	final String? notes;
	final Relationship orderRelation = Relationship(
    required: false,
    array: false,
    relatedCollection: 'orders',
    relationType: RelationshipType.oneToOne,
    twoWay: true,
    twoWayKey: 'invoice',
    onDelete: OnDelete.restrict,
    side: Side.parent,
  );
  final Orders? order;

  Invoices._({
    required this.amount,
		required this.date,
		required this.invoiceNumber,
		required this.name,
		this.notes,
		this.order,
    required super.$id,
    required super.$collectionId,
    required super.$databaseId,
    required super.$createdAt,
    required super.$updatedAt,
    required super.$permissions,
  })  : assert(amount >= -9223372036854775808),
				assert(amount <= 9223372036854775807),
				assert(date.isUtc),
				assert(invoiceNumber.isNotEmpty),
				assert(invoiceNumber.length <= 9),
				assert(name.isNotEmpty),
				assert(name.length <= 64),
				assert(notes == null || notes.isNotEmpty && notes.length <= 256);

  factory Invoices({
    required int amount,
		required DateTime date,
		required String invoiceNumber,
		required String name,
		String? notes,
		Orders? order
  }) {
    return Invoices._(
      amount: amount,
			date: date,
			invoiceNumber: invoiceNumber,
			name: name,
			notes: notes,
			order: order,
      $id: ID.unique(),
      $collectionId: collectionInfo.$id,
      $databaseId: collectionInfo.databaseId,
      $createdAt: DateTime.now().toUtc(),
      $updatedAt: DateTime.now().toUtc(),
      $permissions: collectionInfo.$permissions,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
			'date': date.toIso8601String(),
			'invoiceNumber': invoiceNumber,
			'name': name,
			'notes': notes,
			'order': order?.toJson()
    };
  }

  @override
  Map<String, dynamic> toAppwrite({bool isChild = false}) {
    return {
      'amount': amount,
			'date': date.toIso8601String(),
			'invoiceNumber': invoiceNumber,
			'name': name,
			'notes': notes,
			'order': order?.toAppwrite(isChild: true),
      if (!isChild) '\$id': $id,
    };
  }

  @override
  Invoices copyWith({
    int? amount,
		DateTime? date,
		String? invoiceNumber,
		String? name,
		String? notes,
		Orders? order,
    String? $id,
    String? $collectionId,
    String? $databaseId,
    DateTime? $createdAt,
    DateTime? $updatedAt,
    List<String>? $permissions,
  }) {
    return Invoices._(
      amount: amount ?? this.amount,
			date: date ?? this.date,
			invoiceNumber: invoiceNumber ?? this.invoiceNumber,
			name: name ?? this.name,
			notes: notes ?? this.notes,
			order: order ?? this.order,
      $id: $id ?? this.$id,
      $collectionId: $collectionId ?? this.$collectionId,
      $databaseId: $databaseId ?? this.$databaseId,
      $createdAt: $createdAt ?? this.$createdAt,
      $updatedAt: $updatedAt ?? this.$updatedAt,
      $permissions: $permissions ?? this.$permissions,
    );
  }

  @override
  String toString() {
    return toJson().toString();
  }

  @override
  bool operator ==(Object other) {
    return other is Invoices &&
      amount == other.amount &&
			date == other.date &&
			invoiceNumber == other.invoiceNumber &&
			name == other.name &&
			notes == other.notes &&
			order == other.order &&
      other.$id == $id;
  }

  @override
  int get hashCode {
    return Object.hashAllUnordered([
      amount,
			date,
			invoiceNumber,
			name,
			notes,
			order,
      $id,
    ]);
  }

  factory Invoices.fromAppwrite(Document doc) {
    return Invoices._(
      amount: doc.data['amount'],
			date: DateTime.parse(doc.data['date']),
			invoiceNumber: doc.data['invoiceNumber'],
			name: doc.data['name'],
			notes: doc.data['notes'],
			order: doc.data['order'] == null ? null : Orders.fromAppwrite(Document.fromMap(doc.data['order'])),
      $id: doc.$id,
      $collectionId: doc.$collectionId,
      $databaseId: doc.$databaseId,
      $createdAt: DateTime.parse(doc.$createdAt),
      $updatedAt: DateTime.parse(doc.$updatedAt),
      $permissions: List<String>.unmodifiable(doc.$permissions),
    );
  }

// API

  static AppwriteClient get client => GetIt.I.get<AppwriteClient>();
  static String get databaseId => GetIt.I.get<AppwriteClient>().overrideDatabaseId ?? collectionInfo.databaseId;

  static Future<Result<(int, List<Invoices>), String>> page({
    int limit = 25,
    int? offset,
    Invoices? last,
  }) async {
    return client.page<Invoices>(
      collectionInfo.databaseId,
      collectionInfo.$id,
      Invoices.fromAppwrite,
      limit: limit,
      offset: offset,
      last: last,
    );
  }

  static Future<Result<Invoices, String>> get(String id) async {
    return client.get<Invoices>(
      collectionInfo.databaseId,
      collectionInfo.$id,
      id,
      Invoices.fromAppwrite,
    );
  }

  Future<Result<Invoices, String>> create() async {
    return client.create<Invoices>(
      collectionInfo.databaseId,
      collectionInfo.$id,
      Invoices.fromAppwrite,
      this,
    );
  }

  Future<Result<Invoices, String>> update() async {
    return client.update<Invoices>(
      collectionInfo.databaseId,
      collectionInfo.$id,
      Invoices.fromAppwrite,
      this,
    );
  }

  Future<Result<void, String>> delete() async {
    return client.delete(
      collectionInfo.databaseId,
      collectionInfo.$id,
      $id,
    );
  }
}



class Orders extends AppwriteModel<Orders> {
  static const collectionInfo = CollectionInfo(
    $id: 'orders',
    $permissions: ['create("label:validProductKey")'],
    databaseId: 'dev',
    name: 'orders',
    enabled: true,
    documentSecurity: true,
  );

  final String? city;
	final int customerId;
	final String customerName;
	final DateTime date;
	final Relationship invoiceRelation = Relationship(
    required: false,
    array: false,
    relatedCollection: 'invoices',
    relationType: RelationshipType.oneToOne,
    twoWay: true,
    twoWayKey: 'order',
    onDelete: OnDelete.restrict,
    side: Side.child,
  );
  final Invoices? invoice;
	final Relationship productsRelation = Relationship(
    required: false,
    array: false,
    relatedCollection: 'orderProducts',
    relationType: RelationshipType.oneToMany,
    twoWay: true,
    twoWayKey: 'order',
    onDelete: OnDelete.cascade,
    side: Side.parent,
  );
  final List<OrderProducts>? products;
	final String? street;
	final String? zip;

  Orders._({
    this.city,
		required this.customerId,
		required this.customerName,
		required this.date,
		this.invoice,
		this.products,
		this.street,
		this.zip,
    required super.$id,
    required super.$collectionId,
    required super.$databaseId,
    required super.$createdAt,
    required super.$updatedAt,
    required super.$permissions,
  })  : assert(city == null || city.isNotEmpty && city.length <= 64),
				assert(customerId >= -9223372036854775808),
				assert(customerId <= 9223372036854775807),
				assert(customerName.isNotEmpty),
				assert(customerName.length <= 128),
				assert(date.isUtc),
				assert(street == null || street.isNotEmpty && street.length <= 64),
				assert(zip == null || zip.isNotEmpty && zip.length <= 64);

  factory Orders({
    String? city,
		required int customerId,
		required String customerName,
		required DateTime date,
		Invoices? invoice,
		List<OrderProducts>? products,
		String? street,
		String? zip
  }) {
    return Orders._(
      city: city,
			customerId: customerId,
			customerName: customerName,
			date: date,
			invoice: invoice,
			products: products,
			street: street,
			zip: zip,
      $id: ID.unique(),
      $collectionId: collectionInfo.$id,
      $databaseId: collectionInfo.databaseId,
      $createdAt: DateTime.now().toUtc(),
      $updatedAt: DateTime.now().toUtc(),
      $permissions: collectionInfo.$permissions,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'city': city,
			'customerId': customerId,
			'customerName': customerName,
			'date': date.toIso8601String(),
			'invoice': invoice?.toJson(),
			'products': products?.map((e) => e.toJson()).toList(),
			'street': street,
			'zip': zip
    };
  }

  @override
  Map<String, dynamic> toAppwrite({bool isChild = false}) {
    return {
      'city': city,
			'customerId': customerId,
			'customerName': customerName,
			'date': date.toIso8601String(),
			'invoice': invoice?.toAppwrite(isChild: true),
			'products': products?.map((e) => e.toAppwrite(isChild: true)).toList(),
			'street': street,
			'zip': zip,
      if (!isChild) '\$id': $id,
    };
  }

  @override
  Orders copyWith({
    String? city,
		int? customerId,
		String? customerName,
		DateTime? date,
		Invoices? invoice,
		List<OrderProducts>? products,
		String? street,
		String? zip,
    String? $id,
    String? $collectionId,
    String? $databaseId,
    DateTime? $createdAt,
    DateTime? $updatedAt,
    List<String>? $permissions,
  }) {
    return Orders._(
      city: city ?? this.city,
			customerId: customerId ?? this.customerId,
			customerName: customerName ?? this.customerName,
			date: date ?? this.date,
			invoice: invoice ?? this.invoice,
			products: products ?? this.products,
			street: street ?? this.street,
			zip: zip ?? this.zip,
      $id: $id ?? this.$id,
      $collectionId: $collectionId ?? this.$collectionId,
      $databaseId: $databaseId ?? this.$databaseId,
      $createdAt: $createdAt ?? this.$createdAt,
      $updatedAt: $updatedAt ?? this.$updatedAt,
      $permissions: $permissions ?? this.$permissions,
    );
  }

  @override
  String toString() {
    return toJson().toString();
  }

  @override
  bool operator ==(Object other) {
		final eq = const ListEquality().equals;
    return other is Orders &&
      city == other.city &&
			customerId == other.customerId &&
			customerName == other.customerName &&
			date == other.date &&
			invoice == other.invoice &&
			eq(products, other.products) &&
			street == other.street &&
			zip == other.zip &&
      other.$id == $id;
  }

  @override
  int get hashCode {
    return Object.hashAllUnordered([
      city,
			customerId,
			customerName,
			date,
			invoice,
			...(products ?? []),
			street,
			zip,
      $id,
    ]);
  }

  factory Orders.fromAppwrite(Document doc) {
    return Orders._(
      city: doc.data['city'],
			customerId: doc.data['customerId'],
			customerName: doc.data['customerName'],
			date: DateTime.parse(doc.data['date']),
			invoice: doc.data['invoice'] == null ? null : Invoices.fromAppwrite(Document.fromMap(doc.data['invoice'])),
			products: List<OrderProducts>.unmodifiable(doc.data['products'] == null ? [] : doc.data['products'].map((e) => OrderProducts.fromAppwrite(Document.fromMap(e)))),
			street: doc.data['street'],
			zip: doc.data['zip'],
      $id: doc.$id,
      $collectionId: doc.$collectionId,
      $databaseId: doc.$databaseId,
      $createdAt: DateTime.parse(doc.$createdAt),
      $updatedAt: DateTime.parse(doc.$updatedAt),
      $permissions: List<String>.unmodifiable(doc.$permissions),
    );
  }

// API

  static AppwriteClient get client => GetIt.I.get<AppwriteClient>();
  static String get databaseId => GetIt.I.get<AppwriteClient>().overrideDatabaseId ?? collectionInfo.databaseId;

  static Future<Result<(int, List<Orders>), String>> page({
    int limit = 25,
    int? offset,
    Orders? last,
  }) async {
    return client.page<Orders>(
      collectionInfo.databaseId,
      collectionInfo.$id,
      Orders.fromAppwrite,
      limit: limit,
      offset: offset,
      last: last,
    );
  }

  static Future<Result<Orders, String>> get(String id) async {
    return client.get<Orders>(
      collectionInfo.databaseId,
      collectionInfo.$id,
      id,
      Orders.fromAppwrite,
    );
  }

  Future<Result<Orders, String>> create() async {
    return client.create<Orders>(
      collectionInfo.databaseId,
      collectionInfo.$id,
      Orders.fromAppwrite,
      this,
    );
  }

  Future<Result<Orders, String>> update() async {
    return client.update<Orders>(
      collectionInfo.databaseId,
      collectionInfo.$id,
      Orders.fromAppwrite,
      this,
    );
  }

  Future<Result<void, String>> delete() async {
    return client.delete(
      collectionInfo.databaseId,
      collectionInfo.$id,
      $id,
    );
  }
}



class OrderProducts extends AppwriteModel<OrderProducts> {
  static const collectionInfo = CollectionInfo(
    $id: 'orderProducts',
    $permissions: ['create("label:validProductKey")'],
    databaseId: 'dev',
    name: 'orderProducts',
    enabled: true,
    documentSecurity: true,
  );

  final int id;
	final Relationship orderRelation = Relationship(
    required: false,
    array: false,
    relatedCollection: 'orders',
    relationType: RelationshipType.oneToMany,
    twoWay: true,
    twoWayKey: 'products',
    onDelete: OnDelete.cascade,
    side: Side.child,
  );
  final Orders? order;
	final int price;
	final int quantity;
	final String title;

  OrderProducts._({
    required this.id,
		this.order,
		required this.price,
		required this.quantity,
		required this.title,
    required super.$id,
    required super.$collectionId,
    required super.$databaseId,
    required super.$createdAt,
    required super.$updatedAt,
    required super.$permissions,
  })  : assert(id >= -9223372036854775808),
				assert(id <= 9223372036854775807),
				assert(price >= -9223372036854775808),
				assert(price <= 9223372036854775807),
				assert(quantity >= 1),
				assert(quantity <= 9223372036854775807),
				assert(title.isNotEmpty),
				assert(title.length <= 64);

  factory OrderProducts({
    required int id,
		Orders? order,
		required int price,
		required int quantity,
		required String title
  }) {
    return OrderProducts._(
      id: id,
			order: order,
			price: price,
			quantity: quantity,
			title: title,
      $id: ID.unique(),
      $collectionId: collectionInfo.$id,
      $databaseId: collectionInfo.databaseId,
      $createdAt: DateTime.now().toUtc(),
      $updatedAt: DateTime.now().toUtc(),
      $permissions: collectionInfo.$permissions,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
			'order': order?.toJson(),
			'price': price,
			'quantity': quantity,
			'title': title
    };
  }

  @override
  Map<String, dynamic> toAppwrite({bool isChild = false}) {
    return {
      'id': id,
			'order': order?.toAppwrite(isChild: true),
			'price': price,
			'quantity': quantity,
			'title': title,
      if (!isChild) '\$id': $id,
    };
  }

  @override
  OrderProducts copyWith({
    int? id,
		Orders? order,
		int? price,
		int? quantity,
		String? title,
    String? $id,
    String? $collectionId,
    String? $databaseId,
    DateTime? $createdAt,
    DateTime? $updatedAt,
    List<String>? $permissions,
  }) {
    return OrderProducts._(
      id: id ?? this.id,
			order: order ?? this.order,
			price: price ?? this.price,
			quantity: quantity ?? this.quantity,
			title: title ?? this.title,
      $id: $id ?? this.$id,
      $collectionId: $collectionId ?? this.$collectionId,
      $databaseId: $databaseId ?? this.$databaseId,
      $createdAt: $createdAt ?? this.$createdAt,
      $updatedAt: $updatedAt ?? this.$updatedAt,
      $permissions: $permissions ?? this.$permissions,
    );
  }

  @override
  String toString() {
    return toJson().toString();
  }

  @override
  bool operator ==(Object other) {
    return other is OrderProducts &&
      id == other.id &&
			order == other.order &&
			price == other.price &&
			quantity == other.quantity &&
			title == other.title &&
      other.$id == $id;
  }

  @override
  int get hashCode {
    return Object.hashAllUnordered([
      id,
			order,
			price,
			quantity,
			title,
      $id,
    ]);
  }

  factory OrderProducts.fromAppwrite(Document doc) {
    return OrderProducts._(
      id: doc.data['id'],
			order: doc.data['order'] == null ? null : Orders.fromAppwrite(Document.fromMap(doc.data['order'])),
			price: doc.data['price'],
			quantity: doc.data['quantity'],
			title: doc.data['title'],
      $id: doc.$id,
      $collectionId: doc.$collectionId,
      $databaseId: doc.$databaseId,
      $createdAt: DateTime.parse(doc.$createdAt),
      $updatedAt: DateTime.parse(doc.$updatedAt),
      $permissions: List<String>.unmodifiable(doc.$permissions),
    );
  }

// API

  static AppwriteClient get client => GetIt.I.get<AppwriteClient>();
  static String get databaseId => GetIt.I.get<AppwriteClient>().overrideDatabaseId ?? collectionInfo.databaseId;

  static Future<Result<(int, List<OrderProducts>), String>> page({
    int limit = 25,
    int? offset,
    OrderProducts? last,
  }) async {
    return client.page<OrderProducts>(
      collectionInfo.databaseId,
      collectionInfo.$id,
      OrderProducts.fromAppwrite,
      limit: limit,
      offset: offset,
      last: last,
    );
  }

  static Future<Result<OrderProducts, String>> get(String id) async {
    return client.get<OrderProducts>(
      collectionInfo.databaseId,
      collectionInfo.$id,
      id,
      OrderProducts.fromAppwrite,
    );
  }

  Future<Result<OrderProducts, String>> create() async {
    return client.create<OrderProducts>(
      collectionInfo.databaseId,
      collectionInfo.$id,
      OrderProducts.fromAppwrite,
      this,
    );
  }

  Future<Result<OrderProducts, String>> update() async {
    return client.update<OrderProducts>(
      collectionInfo.databaseId,
      collectionInfo.$id,
      OrderProducts.fromAppwrite,
      this,
    );
  }

  Future<Result<void, String>> delete() async {
    return client.delete(
      collectionInfo.databaseId,
      collectionInfo.$id,
      $id,
    );
  }
}



class Products extends AppwriteModel<Products> {
  static const collectionInfo = CollectionInfo(
    $id: 'products',
    $permissions: [],
    databaseId: 'public',
    name: 'products',
    enabled: true,
    documentSecurity: false,
  );

  final String? alternateId;
	final DateTime beginSaleDate;
	final bool canBePurchased;
	final List<String> categorySlugs;
	final List<String> color;
	final String culture;
	final String description;
	final DateTime endSaleDate;
	final List<String> excludeFrom;
	final List<String> exclusiveTo;
	final String formattedItemPrice;
	final String formattedOriginalItemPrice;
	final bool hasSalePrice;
	final String? hoverImage;
	final int id;
	final List<String> images;
	final String inventoryStatus;
	final bool isCommissionable;
	final int itemPrice;
	final List<String> languages;
	final DateTime launchDate;
	final List<String> lifeCycleStates;
	final String? metaDescription;
	final String? metaTitle;
	final String offeringType;
	final int originalItemPrice;
	final int qtyLimit;
	final List<String> qualifier;
	final int? replacementForItemId;
	final String slug;
	final String title;

  Products._({
    this.alternateId,
		required this.beginSaleDate,
		required this.canBePurchased,
		required this.categorySlugs,
		required this.color,
		required this.culture,
		required this.description,
		required this.endSaleDate,
		required this.excludeFrom,
		required this.exclusiveTo,
		required this.formattedItemPrice,
		required this.formattedOriginalItemPrice,
		required this.hasSalePrice,
		this.hoverImage,
		required this.id,
		required this.images,
		required this.inventoryStatus,
		required this.isCommissionable,
		required this.itemPrice,
		required this.languages,
		required this.launchDate,
		required this.lifeCycleStates,
		this.metaDescription,
		this.metaTitle,
		required this.offeringType,
		required this.originalItemPrice,
		required this.qtyLimit,
		required this.qualifier,
		this.replacementForItemId,
		required this.slug,
		required this.title,
    required super.$id,
    required super.$collectionId,
    required super.$databaseId,
    required super.$createdAt,
    required super.$updatedAt,
    required super.$permissions,
  })  : assert(alternateId == null || alternateId.isNotEmpty && alternateId.length <= 64),
				assert(beginSaleDate.isUtc),
				assert(categorySlugs.length <= 1024),
				assert(color.length <= 64),
				assert(culture.isNotEmpty),
				assert(culture.length <= 64),
				assert(description.isNotEmpty),
				assert(description.length <= 4096),
				assert(endSaleDate.isUtc),
				assert(excludeFrom.length <= 64),
				assert(exclusiveTo.length <= 64),
				assert(formattedItemPrice.isNotEmpty),
				assert(formattedItemPrice.length <= 64),
				assert(formattedOriginalItemPrice.isNotEmpty),
				assert(formattedOriginalItemPrice.length <= 64),
				assert(hoverImage == null || hoverImage.isNotEmpty && hoverImage.length <= 1024),
				assert(id >= -9223372036854775808),
				assert(id <= 9223372036854775807),
				assert(images.length <= 64),
				assert(inventoryStatus.isNotEmpty),
				assert(inventoryStatus.length <= 64),
				assert(itemPrice >= -9223372036854775808),
				assert(itemPrice <= 9223372036854775807),
				assert(languages.length <= 64),
				assert(launchDate.isUtc),
				assert(lifeCycleStates.length <= 64),
				assert(metaDescription == null || metaDescription.isNotEmpty && metaDescription.length <= 4096),
				assert(metaTitle == null || metaTitle.isNotEmpty && metaTitle.length <= 1024),
				assert(offeringType.isNotEmpty),
				assert(offeringType.length <= 64),
				assert(originalItemPrice >= -9223372036854775808),
				assert(originalItemPrice <= 9223372036854775807),
				assert(qtyLimit >= -9223372036854775808),
				assert(qtyLimit <= 9223372036854775807),
				assert(qualifier.length <= 64),
				assert(replacementForItemId == null || replacementForItemId >= -9223372036854775808),
				assert(replacementForItemId == null || replacementForItemId <= 9223372036854775807),
				assert(slug.isNotEmpty),
				assert(slug.length <= 1024),
				assert(title.isNotEmpty),
				assert(title.length <= 1024);

  factory Products({
    String? alternateId,
		required DateTime beginSaleDate,
		required bool canBePurchased,
		required List<String> categorySlugs,
		required List<String> color,
		required String culture,
		required String description,
		required DateTime endSaleDate,
		required List<String> excludeFrom,
		required List<String> exclusiveTo,
		required String formattedItemPrice,
		required String formattedOriginalItemPrice,
		required bool hasSalePrice,
		String? hoverImage,
		required int id,
		required List<String> images,
		required String inventoryStatus,
		required bool isCommissionable,
		required int itemPrice,
		required List<String> languages,
		required DateTime launchDate,
		required List<String> lifeCycleStates,
		String? metaDescription,
		String? metaTitle,
		required String offeringType,
		required int originalItemPrice,
		required int qtyLimit,
		required List<String> qualifier,
		int? replacementForItemId,
		required String slug,
		required String title
  }) {
    return Products._(
      alternateId: alternateId,
			beginSaleDate: beginSaleDate,
			canBePurchased: canBePurchased,
			categorySlugs: categorySlugs,
			color: color,
			culture: culture,
			description: description,
			endSaleDate: endSaleDate,
			excludeFrom: excludeFrom,
			exclusiveTo: exclusiveTo,
			formattedItemPrice: formattedItemPrice,
			formattedOriginalItemPrice: formattedOriginalItemPrice,
			hasSalePrice: hasSalePrice,
			hoverImage: hoverImage,
			id: id,
			images: images,
			inventoryStatus: inventoryStatus,
			isCommissionable: isCommissionable,
			itemPrice: itemPrice,
			languages: languages,
			launchDate: launchDate,
			lifeCycleStates: lifeCycleStates,
			metaDescription: metaDescription,
			metaTitle: metaTitle,
			offeringType: offeringType,
			originalItemPrice: originalItemPrice,
			qtyLimit: qtyLimit,
			qualifier: qualifier,
			replacementForItemId: replacementForItemId,
			slug: slug,
			title: title,
      $id: ID.unique(),
      $collectionId: collectionInfo.$id,
      $databaseId: collectionInfo.databaseId,
      $createdAt: DateTime.now().toUtc(),
      $updatedAt: DateTime.now().toUtc(),
      $permissions: collectionInfo.$permissions,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'alternateId': alternateId,
			'beginSaleDate': beginSaleDate.toIso8601String(),
			'canBePurchased': canBePurchased,
			'categorySlugs': categorySlugs,
			'color': color,
			'culture': culture,
			'description': description,
			'endSaleDate': endSaleDate.toIso8601String(),
			'excludeFrom': excludeFrom,
			'exclusiveTo': exclusiveTo,
			'formattedItemPrice': formattedItemPrice,
			'formattedOriginalItemPrice': formattedOriginalItemPrice,
			'hasSalePrice': hasSalePrice,
			'hoverImage': hoverImage,
			'id': id,
			'images': images,
			'inventoryStatus': inventoryStatus,
			'isCommissionable': isCommissionable,
			'itemPrice': itemPrice,
			'languages': languages,
			'launchDate': launchDate.toIso8601String(),
			'lifeCycleStates': lifeCycleStates,
			'metaDescription': metaDescription,
			'metaTitle': metaTitle,
			'offeringType': offeringType,
			'originalItemPrice': originalItemPrice,
			'qtyLimit': qtyLimit,
			'qualifier': qualifier,
			'replacementForItemId': replacementForItemId,
			'slug': slug,
			'title': title
    };
  }

  @override
  Map<String, dynamic> toAppwrite({bool isChild = false}) {
    return {
      'alternateId': alternateId,
			'beginSaleDate': beginSaleDate.toIso8601String(),
			'canBePurchased': canBePurchased,
			'categorySlugs': categorySlugs,
			'color': color,
			'culture': culture,
			'description': description,
			'endSaleDate': endSaleDate.toIso8601String(),
			'excludeFrom': excludeFrom,
			'exclusiveTo': exclusiveTo,
			'formattedItemPrice': formattedItemPrice,
			'formattedOriginalItemPrice': formattedOriginalItemPrice,
			'hasSalePrice': hasSalePrice,
			'hoverImage': hoverImage,
			'id': id,
			'images': images,
			'inventoryStatus': inventoryStatus,
			'isCommissionable': isCommissionable,
			'itemPrice': itemPrice,
			'languages': languages,
			'launchDate': launchDate.toIso8601String(),
			'lifeCycleStates': lifeCycleStates,
			'metaDescription': metaDescription,
			'metaTitle': metaTitle,
			'offeringType': offeringType,
			'originalItemPrice': originalItemPrice,
			'qtyLimit': qtyLimit,
			'qualifier': qualifier,
			'replacementForItemId': replacementForItemId,
			'slug': slug,
			'title': title,
      if (!isChild) '\$id': $id,
    };
  }

  @override
  Products copyWith({
    String? alternateId,
		DateTime? beginSaleDate,
		bool? canBePurchased,
		List<String>? categorySlugs,
		List<String>? color,
		String? culture,
		String? description,
		DateTime? endSaleDate,
		List<String>? excludeFrom,
		List<String>? exclusiveTo,
		String? formattedItemPrice,
		String? formattedOriginalItemPrice,
		bool? hasSalePrice,
		String? hoverImage,
		int? id,
		List<String>? images,
		String? inventoryStatus,
		bool? isCommissionable,
		int? itemPrice,
		List<String>? languages,
		DateTime? launchDate,
		List<String>? lifeCycleStates,
		String? metaDescription,
		String? metaTitle,
		String? offeringType,
		int? originalItemPrice,
		int? qtyLimit,
		List<String>? qualifier,
		int? replacementForItemId,
		String? slug,
		String? title,
    String? $id,
    String? $collectionId,
    String? $databaseId,
    DateTime? $createdAt,
    DateTime? $updatedAt,
    List<String>? $permissions,
  }) {
    return Products._(
      alternateId: alternateId ?? this.alternateId,
			beginSaleDate: beginSaleDate ?? this.beginSaleDate,
			canBePurchased: canBePurchased ?? this.canBePurchased,
			categorySlugs: categorySlugs ?? this.categorySlugs,
			color: color ?? this.color,
			culture: culture ?? this.culture,
			description: description ?? this.description,
			endSaleDate: endSaleDate ?? this.endSaleDate,
			excludeFrom: excludeFrom ?? this.excludeFrom,
			exclusiveTo: exclusiveTo ?? this.exclusiveTo,
			formattedItemPrice: formattedItemPrice ?? this.formattedItemPrice,
			formattedOriginalItemPrice: formattedOriginalItemPrice ?? this.formattedOriginalItemPrice,
			hasSalePrice: hasSalePrice ?? this.hasSalePrice,
			hoverImage: hoverImage ?? this.hoverImage,
			id: id ?? this.id,
			images: images ?? this.images,
			inventoryStatus: inventoryStatus ?? this.inventoryStatus,
			isCommissionable: isCommissionable ?? this.isCommissionable,
			itemPrice: itemPrice ?? this.itemPrice,
			languages: languages ?? this.languages,
			launchDate: launchDate ?? this.launchDate,
			lifeCycleStates: lifeCycleStates ?? this.lifeCycleStates,
			metaDescription: metaDescription ?? this.metaDescription,
			metaTitle: metaTitle ?? this.metaTitle,
			offeringType: offeringType ?? this.offeringType,
			originalItemPrice: originalItemPrice ?? this.originalItemPrice,
			qtyLimit: qtyLimit ?? this.qtyLimit,
			qualifier: qualifier ?? this.qualifier,
			replacementForItemId: replacementForItemId ?? this.replacementForItemId,
			slug: slug ?? this.slug,
			title: title ?? this.title,
      $id: $id ?? this.$id,
      $collectionId: $collectionId ?? this.$collectionId,
      $databaseId: $databaseId ?? this.$databaseId,
      $createdAt: $createdAt ?? this.$createdAt,
      $updatedAt: $updatedAt ?? this.$updatedAt,
      $permissions: $permissions ?? this.$permissions,
    );
  }

  @override
  String toString() {
    return toJson().toString();
  }

  @override
  bool operator ==(Object other) {
		final eq = const ListEquality().equals;
    return other is Products &&
      alternateId == other.alternateId &&
			beginSaleDate == other.beginSaleDate &&
			canBePurchased == other.canBePurchased &&
			eq(categorySlugs, other.categorySlugs) &&
			eq(color, other.color) &&
			culture == other.culture &&
			description == other.description &&
			endSaleDate == other.endSaleDate &&
			eq(excludeFrom, other.excludeFrom) &&
			eq(exclusiveTo, other.exclusiveTo) &&
			formattedItemPrice == other.formattedItemPrice &&
			formattedOriginalItemPrice == other.formattedOriginalItemPrice &&
			hasSalePrice == other.hasSalePrice &&
			hoverImage == other.hoverImage &&
			id == other.id &&
			eq(images, other.images) &&
			inventoryStatus == other.inventoryStatus &&
			isCommissionable == other.isCommissionable &&
			itemPrice == other.itemPrice &&
			eq(languages, other.languages) &&
			launchDate == other.launchDate &&
			eq(lifeCycleStates, other.lifeCycleStates) &&
			metaDescription == other.metaDescription &&
			metaTitle == other.metaTitle &&
			offeringType == other.offeringType &&
			originalItemPrice == other.originalItemPrice &&
			qtyLimit == other.qtyLimit &&
			eq(qualifier, other.qualifier) &&
			replacementForItemId == other.replacementForItemId &&
			slug == other.slug &&
			title == other.title &&
      other.$id == $id;
  }

  @override
  int get hashCode {
    return Object.hashAllUnordered([
      alternateId,
			beginSaleDate,
			canBePurchased,
			...categorySlugs,
			...color,
			culture,
			description,
			endSaleDate,
			...excludeFrom,
			...exclusiveTo,
			formattedItemPrice,
			formattedOriginalItemPrice,
			hasSalePrice,
			hoverImage,
			id,
			...images,
			inventoryStatus,
			isCommissionable,
			itemPrice,
			...languages,
			launchDate,
			...lifeCycleStates,
			metaDescription,
			metaTitle,
			offeringType,
			originalItemPrice,
			qtyLimit,
			...qualifier,
			replacementForItemId,
			slug,
			title,
      $id,
    ]);
  }

  factory Products.fromAppwrite(Document doc) {
    return Products._(
      alternateId: doc.data['alternateId'],
			beginSaleDate: DateTime.parse(doc.data['beginSaleDate']),
			canBePurchased: doc.data['canBePurchased'],
			categorySlugs: List<String>.unmodifiable(doc.data['categorySlugs'].map((e) => doc.data['categorySlugs'])),
			color: List<String>.unmodifiable(doc.data['color'].map((e) => doc.data['color'])),
			culture: doc.data['culture'],
			description: doc.data['description'],
			endSaleDate: DateTime.parse(doc.data['endSaleDate']),
			excludeFrom: List<String>.unmodifiable(doc.data['excludeFrom'].map((e) => doc.data['excludeFrom'])),
			exclusiveTo: List<String>.unmodifiable(doc.data['exclusiveTo'].map((e) => doc.data['exclusiveTo'])),
			formattedItemPrice: doc.data['formattedItemPrice'],
			formattedOriginalItemPrice: doc.data['formattedOriginalItemPrice'],
			hasSalePrice: doc.data['hasSalePrice'],
			hoverImage: doc.data['hoverImage'],
			id: doc.data['id'],
			images: List<String>.unmodifiable(doc.data['images'].map((e) => doc.data['images'])),
			inventoryStatus: doc.data['inventoryStatus'],
			isCommissionable: doc.data['isCommissionable'],
			itemPrice: doc.data['itemPrice'],
			languages: List<String>.unmodifiable(doc.data['languages'].map((e) => doc.data['languages'])),
			launchDate: DateTime.parse(doc.data['launchDate']),
			lifeCycleStates: List<String>.unmodifiable(doc.data['lifeCycleStates'].map((e) => doc.data['lifeCycleStates'])),
			metaDescription: doc.data['metaDescription'],
			metaTitle: doc.data['metaTitle'],
			offeringType: doc.data['offeringType'],
			originalItemPrice: doc.data['originalItemPrice'],
			qtyLimit: doc.data['qtyLimit'],
			qualifier: List<String>.unmodifiable(doc.data['qualifier'].map((e) => doc.data['qualifier'])),
			replacementForItemId: doc.data['replacementForItemId'],
			slug: doc.data['slug'],
			title: doc.data['title'],
      $id: doc.$id,
      $collectionId: doc.$collectionId,
      $databaseId: doc.$databaseId,
      $createdAt: DateTime.parse(doc.$createdAt),
      $updatedAt: DateTime.parse(doc.$updatedAt),
      $permissions: List<String>.unmodifiable(doc.$permissions),
    );
  }

// API

  static AppwriteClient get client => GetIt.I.get<AppwriteClient>();
  static String get databaseId => GetIt.I.get<AppwriteClient>().overrideDatabaseId ?? collectionInfo.databaseId;

  static Future<Result<(int, List<Products>), String>> page({
    int limit = 25,
    int? offset,
    Products? last,
  }) async {
    return client.page<Products>(
      collectionInfo.databaseId,
      collectionInfo.$id,
      Products.fromAppwrite,
      limit: limit,
      offset: offset,
      last: last,
    );
  }

  static Future<Result<Products, String>> get(String id) async {
    return client.get<Products>(
      collectionInfo.databaseId,
      collectionInfo.$id,
      id,
      Products.fromAppwrite,
    );
  }

  Future<Result<Products, String>> create() async {
    return client.create<Products>(
      collectionInfo.databaseId,
      collectionInfo.$id,
      Products.fromAppwrite,
      this,
    );
  }

  Future<Result<Products, String>> update() async {
    return client.update<Products>(
      collectionInfo.databaseId,
      collectionInfo.$id,
      Products.fromAppwrite,
      this,
    );
  }

  Future<Result<void, String>> delete() async {
    return client.delete(
      collectionInfo.databaseId,
      collectionInfo.$id,
      $id,
    );
  }
}



class Expenses extends AppwriteModel<Expenses> {
  static const collectionInfo = CollectionInfo(
    $id: 'expenses',
    $permissions: ['create("label:validProductKey")'],
    databaseId: 'dev',
    name: 'expenses',
    enabled: true,
    documentSecurity: true,
  );

  final int amount;
	final DateTime date;
	final String expenseNumber;
	final String name;
	final String? notes;

  Expenses._({
    required this.amount,
		required this.date,
		required this.expenseNumber,
		required this.name,
		this.notes,
    required super.$id,
    required super.$collectionId,
    required super.$databaseId,
    required super.$createdAt,
    required super.$updatedAt,
    required super.$permissions,
  })  : assert(amount >= -9223372036854775808),
				assert(amount <= 9223372036854775807),
				assert(date.isUtc),
				assert(expenseNumber.isNotEmpty),
				assert(expenseNumber.length <= 8),
				assert(name.isNotEmpty),
				assert(name.length <= 64),
				assert(notes == null || notes.isNotEmpty && notes.length <= 256);

  factory Expenses({
    required int amount,
		required DateTime date,
		required String expenseNumber,
		required String name,
		String? notes
  }) {
    return Expenses._(
      amount: amount,
			date: date,
			expenseNumber: expenseNumber,
			name: name,
			notes: notes,
      $id: ID.unique(),
      $collectionId: collectionInfo.$id,
      $databaseId: collectionInfo.databaseId,
      $createdAt: DateTime.now().toUtc(),
      $updatedAt: DateTime.now().toUtc(),
      $permissions: collectionInfo.$permissions,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
			'date': date.toIso8601String(),
			'expenseNumber': expenseNumber,
			'name': name,
			'notes': notes
    };
  }

  @override
  Map<String, dynamic> toAppwrite({bool isChild = false}) {
    return {
      'amount': amount,
			'date': date.toIso8601String(),
			'expenseNumber': expenseNumber,
			'name': name,
			'notes': notes,
      if (!isChild) '\$id': $id,
    };
  }

  @override
  Expenses copyWith({
    int? amount,
		DateTime? date,
		String? expenseNumber,
		String? name,
		String? notes,
    String? $id,
    String? $collectionId,
    String? $databaseId,
    DateTime? $createdAt,
    DateTime? $updatedAt,
    List<String>? $permissions,
  }) {
    return Expenses._(
      amount: amount ?? this.amount,
			date: date ?? this.date,
			expenseNumber: expenseNumber ?? this.expenseNumber,
			name: name ?? this.name,
			notes: notes ?? this.notes,
      $id: $id ?? this.$id,
      $collectionId: $collectionId ?? this.$collectionId,
      $databaseId: $databaseId ?? this.$databaseId,
      $createdAt: $createdAt ?? this.$createdAt,
      $updatedAt: $updatedAt ?? this.$updatedAt,
      $permissions: $permissions ?? this.$permissions,
    );
  }

  @override
  String toString() {
    return toJson().toString();
  }

  @override
  bool operator ==(Object other) {
    return other is Expenses &&
      amount == other.amount &&
			date == other.date &&
			expenseNumber == other.expenseNumber &&
			name == other.name &&
			notes == other.notes &&
      other.$id == $id;
  }

  @override
  int get hashCode {
    return Object.hashAllUnordered([
      amount,
			date,
			expenseNumber,
			name,
			notes,
      $id,
    ]);
  }

  factory Expenses.fromAppwrite(Document doc) {
    return Expenses._(
      amount: doc.data['amount'],
			date: DateTime.parse(doc.data['date']),
			expenseNumber: doc.data['expenseNumber'],
			name: doc.data['name'],
			notes: doc.data['notes'],
      $id: doc.$id,
      $collectionId: doc.$collectionId,
      $databaseId: doc.$databaseId,
      $createdAt: DateTime.parse(doc.$createdAt),
      $updatedAt: DateTime.parse(doc.$updatedAt),
      $permissions: List<String>.unmodifiable(doc.$permissions),
    );
  }

// API

  static AppwriteClient get client => GetIt.I.get<AppwriteClient>();
  static String get databaseId => GetIt.I.get<AppwriteClient>().overrideDatabaseId ?? collectionInfo.databaseId;

  static Future<Result<(int, List<Expenses>), String>> page({
    int limit = 25,
    int? offset,
    Expenses? last,
  }) async {
    return client.page<Expenses>(
      collectionInfo.databaseId,
      collectionInfo.$id,
      Expenses.fromAppwrite,
      limit: limit,
      offset: offset,
      last: last,
    );
  }

  static Future<Result<Expenses, String>> get(String id) async {
    return client.get<Expenses>(
      collectionInfo.databaseId,
      collectionInfo.$id,
      id,
      Expenses.fromAppwrite,
    );
  }

  Future<Result<Expenses, String>> create() async {
    return client.create<Expenses>(
      collectionInfo.databaseId,
      collectionInfo.$id,
      Expenses.fromAppwrite,
      this,
    );
  }

  Future<Result<Expenses, String>> update() async {
    return client.update<Expenses>(
      collectionInfo.databaseId,
      collectionInfo.$id,
      Expenses.fromAppwrite,
      this,
    );
  }

  Future<Result<void, String>> delete() async {
    return client.delete(
      collectionInfo.databaseId,
      collectionInfo.$id,
      $id,
    );
  }
}


enum Type {
  plain,
	withParticipants,
}
  
class CalendarEvents extends AppwriteModel<CalendarEvents> {
  static const collectionInfo = CollectionInfo(
    $id: 'calendarEvents',
    $permissions: ['create("label:validProductKey")'],
    databaseId: 'dev',
    name: 'calendarEvents',
    enabled: true,
    documentSecurity: true,
  );

  final int? amount;
	final String? description;
	final DateTime end;
	final Relationship participantsRelation = Relationship(
    required: false,
    array: false,
    relatedCollection: 'calendarEventParticipants',
    relationType: RelationshipType.oneToMany,
    twoWay: true,
    twoWayKey: 'event',
    onDelete: OnDelete.cascade,
    side: Side.parent,
  );
  final List<CalendarEventParticipants>? participants;
	final DateTime start;
	final String title;
	final Type type;

  CalendarEvents._({
    this.amount,
		this.description,
		required this.end,
		this.participants,
		required this.start,
		required this.title,
		required this.type,
    required super.$id,
    required super.$collectionId,
    required super.$databaseId,
    required super.$createdAt,
    required super.$updatedAt,
    required super.$permissions,
  })  : assert(amount == null || amount >= -9223372036854775808),
				assert(amount == null || amount <= 9223372036854775807),
				assert(description == null || description.isNotEmpty && description.length <= 1024),
				assert(end.isUtc),
				assert(start.isUtc),
				assert(title.isNotEmpty),
				assert(title.length <= 64);

  factory CalendarEvents({
    int? amount,
		String? description,
		required DateTime end,
		List<CalendarEventParticipants>? participants,
		required DateTime start,
		required String title,
		required Type type
  }) {
    return CalendarEvents._(
      amount: amount,
			description: description,
			end: end,
			participants: participants,
			start: start,
			title: title,
			type: type,
      $id: ID.unique(),
      $collectionId: collectionInfo.$id,
      $databaseId: collectionInfo.databaseId,
      $createdAt: DateTime.now().toUtc(),
      $updatedAt: DateTime.now().toUtc(),
      $permissions: collectionInfo.$permissions,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
			'description': description,
			'end': end.toIso8601String(),
			'participants': participants?.map((e) => e.toJson()).toList(),
			'start': start.toIso8601String(),
			'title': title,
			'type': type.name
    };
  }

  @override
  Map<String, dynamic> toAppwrite({bool isChild = false}) {
    return {
      'amount': amount,
			'description': description,
			'end': end.toIso8601String(),
			'participants': participants?.map((e) => e.toAppwrite(isChild: true)).toList(),
			'start': start.toIso8601String(),
			'title': title,
			'type': type.name,
      if (!isChild) '\$id': $id,
    };
  }

  @override
  CalendarEvents copyWith({
    int? amount,
		String? description,
		DateTime? end,
		List<CalendarEventParticipants>? participants,
		DateTime? start,
		String? title,
		Type? type,
    String? $id,
    String? $collectionId,
    String? $databaseId,
    DateTime? $createdAt,
    DateTime? $updatedAt,
    List<String>? $permissions,
  }) {
    return CalendarEvents._(
      amount: amount ?? this.amount,
			description: description ?? this.description,
			end: end ?? this.end,
			participants: participants ?? this.participants,
			start: start ?? this.start,
			title: title ?? this.title,
			type: type ?? this.type,
      $id: $id ?? this.$id,
      $collectionId: $collectionId ?? this.$collectionId,
      $databaseId: $databaseId ?? this.$databaseId,
      $createdAt: $createdAt ?? this.$createdAt,
      $updatedAt: $updatedAt ?? this.$updatedAt,
      $permissions: $permissions ?? this.$permissions,
    );
  }

  @override
  String toString() {
    return toJson().toString();
  }

  @override
  bool operator ==(Object other) {
		final eq = const ListEquality().equals;
    return other is CalendarEvents &&
      amount == other.amount &&
			description == other.description &&
			end == other.end &&
			eq(participants, other.participants) &&
			start == other.start &&
			title == other.title &&
			type == other.type &&
      other.$id == $id;
  }

  @override
  int get hashCode {
    return Object.hashAllUnordered([
      amount,
			description,
			end,
			...(participants ?? []),
			start,
			title,
			type,
      $id,
    ]);
  }

  factory CalendarEvents.fromAppwrite(Document doc) {
    return CalendarEvents._(
      amount: doc.data['amount'],
			description: doc.data['description'],
			end: DateTime.parse(doc.data['end']),
			participants: List<CalendarEventParticipants>.unmodifiable(doc.data['participants'] == null ? [] : doc.data['participants'].map((e) => CalendarEventParticipants.fromAppwrite(Document.fromMap(e)))),
			start: DateTime.parse(doc.data['start']),
			title: doc.data['title'],
			type: Type.values.byName(doc.data['type']),
      $id: doc.$id,
      $collectionId: doc.$collectionId,
      $databaseId: doc.$databaseId,
      $createdAt: DateTime.parse(doc.$createdAt),
      $updatedAt: DateTime.parse(doc.$updatedAt),
      $permissions: List<String>.unmodifiable(doc.$permissions),
    );
  }

// API

  static AppwriteClient get client => GetIt.I.get<AppwriteClient>();
  static String get databaseId => GetIt.I.get<AppwriteClient>().overrideDatabaseId ?? collectionInfo.databaseId;

  static Future<Result<(int, List<CalendarEvents>), String>> page({
    int limit = 25,
    int? offset,
    CalendarEvents? last,
  }) async {
    return client.page<CalendarEvents>(
      collectionInfo.databaseId,
      collectionInfo.$id,
      CalendarEvents.fromAppwrite,
      limit: limit,
      offset: offset,
      last: last,
    );
  }

  static Future<Result<CalendarEvents, String>> get(String id) async {
    return client.get<CalendarEvents>(
      collectionInfo.databaseId,
      collectionInfo.$id,
      id,
      CalendarEvents.fromAppwrite,
    );
  }

  Future<Result<CalendarEvents, String>> create() async {
    return client.create<CalendarEvents>(
      collectionInfo.databaseId,
      collectionInfo.$id,
      CalendarEvents.fromAppwrite,
      this,
    );
  }

  Future<Result<CalendarEvents, String>> update() async {
    return client.update<CalendarEvents>(
      collectionInfo.databaseId,
      collectionInfo.$id,
      CalendarEvents.fromAppwrite,
      this,
    );
  }

  Future<Result<void, String>> delete() async {
    return client.delete(
      collectionInfo.databaseId,
      collectionInfo.$id,
      $id,
    );
  }
}


enum Status {
  accepted,
	declined,
	pending,
}
  
class CalendarEventParticipants extends AppwriteModel<CalendarEventParticipants> {
  static const collectionInfo = CollectionInfo(
    $id: 'calendarEventParticipants',
    $permissions: ['create("label:validProductKey")'],
    databaseId: 'dev',
    name: 'calendarEventParticipants',
    enabled: true,
    documentSecurity: true,
  );

  final Relationship customerRelation = Relationship(
    required: false,
    array: false,
    relatedCollection: 'customers',
    relationType: RelationshipType.manyToOne,
    twoWay: true,
    twoWayKey: 'calendarEvents',
    onDelete: OnDelete.setNull,
    side: Side.parent,
  );
  final Customers? customer;
	final Relationship eventRelation = Relationship(
    required: false,
    array: false,
    relatedCollection: 'calendarEvents',
    relationType: RelationshipType.oneToMany,
    twoWay: true,
    twoWayKey: 'participants',
    onDelete: OnDelete.cascade,
    side: Side.child,
  );
  final CalendarEvents? event;
	final Status status;

  CalendarEventParticipants._({
    this.customer,
		this.event,
		required this.status,
    required super.$id,
    required super.$collectionId,
    required super.$databaseId,
    required super.$createdAt,
    required super.$updatedAt,
    required super.$permissions,
  });

  factory CalendarEventParticipants({
    Customers? customer,
		CalendarEvents? event,
		required Status status
  }) {
    return CalendarEventParticipants._(
      customer: customer,
			event: event,
			status: status,
      $id: ID.unique(),
      $collectionId: collectionInfo.$id,
      $databaseId: collectionInfo.databaseId,
      $createdAt: DateTime.now().toUtc(),
      $updatedAt: DateTime.now().toUtc(),
      $permissions: collectionInfo.$permissions,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'customer': customer?.toJson(),
			'event': event?.toJson(),
			'status': status.name
    };
  }

  @override
  Map<String, dynamic> toAppwrite({bool isChild = false}) {
    return {
      'customer': customer?.toAppwrite(isChild: true),
			'event': event?.toAppwrite(isChild: true),
			'status': status.name,
      if (!isChild) '\$id': $id,
    };
  }

  @override
  CalendarEventParticipants copyWith({
    Customers? customer,
		CalendarEvents? event,
		Status? status,
    String? $id,
    String? $collectionId,
    String? $databaseId,
    DateTime? $createdAt,
    DateTime? $updatedAt,
    List<String>? $permissions,
  }) {
    return CalendarEventParticipants._(
      customer: customer ?? this.customer,
			event: event ?? this.event,
			status: status ?? this.status,
      $id: $id ?? this.$id,
      $collectionId: $collectionId ?? this.$collectionId,
      $databaseId: $databaseId ?? this.$databaseId,
      $createdAt: $createdAt ?? this.$createdAt,
      $updatedAt: $updatedAt ?? this.$updatedAt,
      $permissions: $permissions ?? this.$permissions,
    );
  }

  @override
  String toString() {
    return toJson().toString();
  }

  @override
  bool operator ==(Object other) {
    return other is CalendarEventParticipants &&
      customer == other.customer &&
			event == other.event &&
			status == other.status &&
      other.$id == $id;
  }

  @override
  int get hashCode {
    return Object.hashAllUnordered([
      customer,
			event,
			status,
      $id,
    ]);
  }

  factory CalendarEventParticipants.fromAppwrite(Document doc) {
    return CalendarEventParticipants._(
      customer: doc.data['customer'] == null ? null : Customers.fromAppwrite(Document.fromMap(doc.data['customer'])),
			event: doc.data['event'] == null ? null : CalendarEvents.fromAppwrite(Document.fromMap(doc.data['event'])),
			status: Status.values.byName(doc.data['status']),
      $id: doc.$id,
      $collectionId: doc.$collectionId,
      $databaseId: doc.$databaseId,
      $createdAt: DateTime.parse(doc.$createdAt),
      $updatedAt: DateTime.parse(doc.$updatedAt),
      $permissions: List<String>.unmodifiable(doc.$permissions),
    );
  }

// API

  static AppwriteClient get client => GetIt.I.get<AppwriteClient>();
  static String get databaseId => GetIt.I.get<AppwriteClient>().overrideDatabaseId ?? collectionInfo.databaseId;

  static Future<Result<(int, List<CalendarEventParticipants>), String>> page({
    int limit = 25,
    int? offset,
    CalendarEventParticipants? last,
  }) async {
    return client.page<CalendarEventParticipants>(
      collectionInfo.databaseId,
      collectionInfo.$id,
      CalendarEventParticipants.fromAppwrite,
      limit: limit,
      offset: offset,
      last: last,
    );
  }

  static Future<Result<CalendarEventParticipants, String>> get(String id) async {
    return client.get<CalendarEventParticipants>(
      collectionInfo.databaseId,
      collectionInfo.$id,
      id,
      CalendarEventParticipants.fromAppwrite,
    );
  }

  Future<Result<CalendarEventParticipants, String>> create() async {
    return client.create<CalendarEventParticipants>(
      collectionInfo.databaseId,
      collectionInfo.$id,
      CalendarEventParticipants.fromAppwrite,
      this,
    );
  }

  Future<Result<CalendarEventParticipants, String>> update() async {
    return client.update<CalendarEventParticipants>(
      collectionInfo.databaseId,
      collectionInfo.$id,
      CalendarEventParticipants.fromAppwrite,
      this,
    );
  }

  Future<Result<void, String>> delete() async {
    return client.delete(
      collectionInfo.databaseId,
      collectionInfo.$id,
      $id,
    );
  }
}
