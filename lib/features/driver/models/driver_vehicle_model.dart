class DriverVehicleModel {
  final int id;
  final int? userId;
  final String placa;
  final String tipoVehiculo;
  final String marca;
  final String modelo;
  final int anho;
  final String color;
  final int capacidad;
  final String? ruat;
  final String? soat;
  final String? inspeccionTecnica;
  final String? fotoVehiculo;
  final bool status;

  DriverVehicleModel({
    required this.id,
    this.userId,
    required this.placa,
    required this.tipoVehiculo,
    required this.marca,
    required this.modelo,
    required this.anho,
    required this.color,
    required this.capacidad,
    this.ruat,
    this.soat,
    this.inspeccionTecnica,
    this.fotoVehiculo,
    required this.status,
  });

  factory DriverVehicleModel.fromJson(Map<String, dynamic> json) {
    return DriverVehicleModel(
      id: json['id'],
      userId: json['user_id'],
      placa: json['placa'] ?? '',
      tipoVehiculo: json['tipo_vehiculo'] ?? '',
      marca: json['marca'] ?? '',
      modelo: json['modelo'] ?? '',
      anho: json['anho'] ?? 2020,
      color: json['color'] ?? '',
      capacidad: json['capacidad'] ?? 4,
      ruat: json['ruat'],
      soat: json['soat'],
      inspeccionTecnica: json['inspeccion_tecnica'],
      fotoVehiculo: json['foto_vehiculo'],
      status: json['status'] == 1 || json['status'] == true,
    );
  }
}