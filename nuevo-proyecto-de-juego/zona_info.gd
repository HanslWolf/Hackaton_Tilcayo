extends Area2D

@export var zona_id: String = ""
@export var titulo: String = ""

# Pega aquí tus datos de la NASA, uno por sala
const DATOS := {
	"comunicaciones": "ALERTA DE COMUNICACIONES\nEstado del enlace: 87% (sim.)\n\nRetraso Luna-Tierra: 1.3 s\nRetraso Marte-Tierra: de 4 a 22 min (ida)\nSi el índice Kp llega a 6 o más, la tormenta geomagnética degrada la señal y corrompe paquetes de datos.",

	"geologia": "GEOLOGÍA E ISRU\nHielo de agua en Cabeus: 5.6% del peso (LCROSS)\nOxígeno atrapado en el regolito: 42% a 45%\nSitio Shackleton: 80% a 90% de luz solar al año\nPercloratos en suelo marciano: 0.5% a 1%\nEl polvo lunar desgasta sellos de trajes y paneles.\nAnálisis del sitio: 35% (sim.)",

	"centro_mando": "CENTRO DE MANDO\nRadiación acumulada: 12% del límite de carrera\n(72 de 600 mSv tras 120 días a 0.6 mSv/día)\nLímite agudo en 30 días: 250 mSv\nTormenta solar sin escudo: +40 mSv en superficie y +150 mSv en tránsito\nRuta: Luna, tránsito, Marte",

	"soporte_vital": "SOPORTE VITAL (ECLSS)\nOxígeno por tripulante: 0.84 kg al día\nAgua potable: 2.5 L al día\nReciclaje de agua: 90% a 98%\nUna caminata EVA sube el consumo a 1.08 kg de O2 al día.\nReserva de oxígeno: 76% (sim.)",

	"alimentos": "ALIMENTOS Y CULTIVOS\nProductividad: 27.4 kg por m² al año (EDEN ISS)\nDieta de la tripulación: 3,035 kcal al día\nCosecha de 268 kg y 26 especies: pepino 25%, lechuga 21%, tomate 19%, hojas verdes 18%\nSin ventilación en microgravedad, la fotosíntesis cae hasta un 30%.\nReserva de comida: 82% (sim.)"
}

var _panel: PanelContainer
var _label: Label


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_crear_ui()


func _crear_ui() -> void:
	var capa := CanvasLayer.new()
	capa.layer = 10
	add_child(capa)

	_panel = PanelContainer.new()
	_panel.position = Vector2(20, 20)
	_panel.custom_minimum_size = Vector2(440, 0)
	_panel.visible = false
	capa.add_child(_panel)

	_label = Label.new()
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.add_theme_font_size_override("font_size", 18)
	_panel.add_child(_label)


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		_label.text = titulo + "\n\n" + DATOS.get(zona_id, "Sin datos")
		_panel.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		_panel.visible = false
