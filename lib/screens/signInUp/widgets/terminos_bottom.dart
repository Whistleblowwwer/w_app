import 'package:flutter/material.dart';
import 'package:w_app/styles/gradient_style.dart';
import 'package:w_app/widgets/press_transform_widget.dart';

class RoundedBottomSheet extends StatefulWidget {
  const RoundedBottomSheet({Key? key}) : super(key: key);

  @override
  _RoundedBottomSheetState createState() => _RoundedBottomSheetState();
}

class _RoundedBottomSheetState extends State<RoundedBottomSheet>
    with SingleTickerProviderStateMixin {
  int currentPage = 0;

  double currentPadding = 0.0; // Valor actual del padding
  final double maxPadding = 40.0; // Valor máximo del padding
  double titleOpacity = 0.0;

  Widget makeDismissible({required Widget child}) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(),
        child: GestureDetector(
          onTap: () {},
          child: child,
        ),
      );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double sizeH = MediaQuery.of(context).size.width / 100;
    double sizeV = MediaQuery.of(context).size.height / 100;

    return makeDismissible(
      child: DraggableScrollableSheet(
        initialChildSize: 0.8, // Altura inicial del BottomSheet (0.0 - 1.0)
        maxChildSize: 1, // Altura máxima del BottomSheet (0.0 - 1.0)
        minChildSize: 0.8, // Altura mínima del BottomSheet (0.0 - 1.0)

        builder: (BuildContext context, ScrollController scrollController) {
          scrollController.addListener(() {
            setState(() {
              final offset = scrollController.offset;
              currentPadding =
                  (offset > maxPadding) ? maxPadding : offset.abs();

              titleOpacity = (offset > maxPadding)
                  ? 1.0
                  : (offset.abs() / maxPadding).clamp(0.0, 1.0);
              ;
              // Limita el valor máximo del padding
            });
          });

          return ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32.0),
              topRight: Radius.circular(32.0),
            ),
            child: Container(
              height: sizeV * 100,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32.0),
                  topRight: Radius.circular(32.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: Offset(0.0, -5.0),
                  ),
                ],
              ),
              child:
                  Stack(alignment: AlignmentDirectional.topCenter, children: [
                Positioned(
                  top: 32,
                  right: 24,
                  left: 24,
                  child: Container(
                    height: sizeV * 100,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: 200, top: 48),
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Aviso de privacidad',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w700),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            """
RESPONSABLE:
ANCER 2023, S.A.P.I. DE C.V., con domicilio en Pedro Infante # 1000, Colonia Cumbres Oro Regency, Monterrey,
Nuevo León. México. 64347, utilizará los datos personales que Usted le proporcione a través de esta página, por
correo electrónico o por cualquier otro medio, únicamente con el propósito de ofrecer y prestar los servicios de
dicha empresa, así como para navegar en sus páginas web. Usted autoriza el tratamiento de su información en los
términos establecidos en este aviso de privacidad, mismo que podrá ser modificado posteriormente.
DATOS PERSONALES:
Los datos personales que se recabarán son:
• Denominación social en caso de tratarse de una sociedad civil o mercantil, o bien el nombre de la
persona física que contrate los servicios a título personal. Asimismo, se recabarán los nombres de
sus administradores y personas que manejarán los servicios proporcionados.
• Nombre completo de la persona física que visite el sitio web, o bien, sus datos de navegación.
• Domicilio, datos de geolocalización, domicilio social, así como domicilio en donde se utilizará el
servicio ofertado o contratado con ANCER 2023, S.A.P.I. DE C.V.
• Información de contacto y localización geográfica, incluyendo pero sin limitarse al correo
electrónico, formularios de la página, formularios físicos, así como geolocalización satelital.
• Ubicación geográfica cuando ingresa al programa de cómputo (app) o página web, incluyendo
ciudad, región, y ubicación exacta.
• Compañía de teléfono móvil o compañía proveedora de servicios de Internet que le brinda acceso
a Internet.
• Direcciones IP de CLIENTES o USUARIOS.
• Datos relacionados con los servicios prestados.
• Datos tecnológicos, que las páginas web normalmente puedan recabar en el curso ordinario de su
operación, los mismos incluyen dirección de IP, así como la utilización de programas y elementos
denominados cookies u otras tecnologías de seguimiento.
• Toda la información recabada por los programas denominados cookies, concernientes a
navegación en otros sitios web, utilización de otros programas de cómputo, así como
características e información del ordenador del usuario. Lo anterior para propósitos tanto de
funcionamiento como mercadotecnia.
FINALIDAD:
La principal finalidad de los datos recabados será su utilización para ofrecer y prestar los servicios de dicha
empresa, así como para navegar en sus páginas web. Los servicios prestados por dicha empresa estarán sujetos
al contrato respectivo, mismo que podrá estar contenido en los términos legales de la página web
WWW.WHISTLEBLOWWER.COM. Los datos a que se refiere el presente AVISO DE PRIVACIDAD, son
necesarios para llevar a cabo dichas operaciones y licencias así como para prestar cualquier servicio relacionado.
TÉRMINO:
En relación con el servicio ofertado, los datos se conservarán por un período de 10 años contados a partir de la
fecha de visita al sitio web o de la fecha de vencimiento del contrato de términos legales disponible en
WWW.WHISTLEBLOWWER.COM, lo que ocurra después. Lo anterior en cumplimiento a disposiciones fiscales y
mercantiles.
COOKIES:
Se utilizan paquetes de datos denominados cookies, tanto persistentes como de sesión. Algunas de las cookies se
podrán utilizar con propósitos de obtener información sobre otros sitios visitados o actividades realizadas en su
ordenador. Asimismo, se utilizarán cookies mientras navega por el sitio con el propósito de hacer más fácil la
navegación y ofrecerle una mejor experiencia. Una vez que Usted ha abandonado el sitio, las cookies de sesión
quedan inhabilitadas. Sin embargo, las cookies persistentes podrán permanecer en el equipo del usuario durante
el período establecido por las mismas. Las cookies de sesión se borran, en la mayoría de los casos al cerrar el
navegador.
DATOS SENSIBLES:
Usualmente, no se recabarán ni utilizarán datos sensibles. Sin embargo, cualquier contrato celebrado por ANCER
2023, S.A.P.I. DE C.V., podrá contener datos sensibles. Lo anterior si por razones de seguridad o cumplimiento a
normas oficiales mexicanas en la prestación del servicio, es necesaria dicha información.
TRANSFERENCIA:
Sus datos personales podrán ser transferidos o compartidos con propósitos de mercadotecnia, investigaciones, o
bien para hacerle llegar cualquier tipo de oferta.
Se transferirán a terceros los datos necesarios para la operación técnica de esta página. Así, al acceder la página,
Usted está de acuerdo en que sus datos los administrará el proveedor de servicios de Internet que la hospeda y
que hace posible su funcionamiento técnico.
Asimismo, cada proceso técnico de la página de Internet, así como la prestación de servicios contratados por Usted
o su representada, puede implicar que su información o la de su representada, sea procesada por algún otro tercer
proveedor de servicios, como por ejemplo algún proveedor de servicios de Internet, o la persona moral que provee
el servicio de telecomunicación.
Considere que su información personal puede salir de su país de origen para efectos de brindarle el servicio o la
propia navegación en la página.
DATOS PROVENIENTES DE TERCEROS
ANCER 2023, S.A.P.I. DE C.V., podrá recolectar datos personales de terceros con propósitos de mercadotecnia,
análisis o cualquier propósito. Para más información en este sentido, puede contactar al administrador, al siguiente
correo electrónico: contacto@whistleblowwer.com. Asimismo, la información contenida en cualquier contrato de
prestación de servicios celebrado puede contener datos personales provenientes de terceros.
DERECHOS ARCO o DERECHOS DE AUTODETERMINACIÓN INFORMATIVA:
De acuerdo con la legislación mexicana, Usted tiene derecho de acceder y conocer los datos personales, que
ANCER 2023, S.A.P.I. DE C.V. ha obtenido de Usted, así como el tratamiento y uso de los mismos. De igual
manera, Usted tiene derecho a rectificarlos, corregirlos, cancelarlos; o bien, eliminarlos en su totalidad cuando así
lo considere. Asimismo, Usted tiene derecho a oponerse al tratamiento de sus datos y solicitar que los mismos
sean eliminados. Tome en cuenta, que el servicio ofertado no se podrá prestar en caso de que Usted decida
oponerse al tratamiento de su información.
Para hacer valer los derechos a que se refiere el párrafo anterior, comuníquese con administrador al correo
electrónico contacto@whistleblowwer.com, quien en un plazo no mayor de 10 días hábiles dará seguimiento a su
solicitud.
PROTECCIÓN DE DATOS
Sus datos personales se encuentran protegidos por las medidas de seguridad técnicas, administrativas y físicas
que normalmente se utilizan en la industria para evitar que los mismos sean substraídos, recolectados o utilizados
ilícitamente por terceras personas utilizando software o métodos maliciosos para tal efecto. No obstante dichos
cuidados o buena diligencia, no se ofrece garantía alguna, ni expresa ni implícita, en caso de que su información
sea accedida, recolectada, substraída, alterada, utilizada, o revelada ilícitamente por algún tercero.
NOTIFICACIÓN DE INCIDENTE DE SEGURIDAD DE DATOS ó “NOTIFICACIÓN DE BRECHAS DE
SEGURIDAD”
Si bien ANCER 2023, S.A.P.I. DE C.V. tiene su domicilio social fuera de la Unión Europea y su actividad no se
dirige primordialmente a personas que viven en la Unión Europea, se prevén las siguientes medidas a fin de dar
cumplimiento al Reglamento General de Protección de Datos (RGPD) emitido por el Parlamento Europeo y el
Consejo de la Unión Europea.
Si los administradores o empleados de ANCER 2023, S.A.P.I. DE C.V., tienen conocimiento de una violación de
seguridad que conduce a cualquier acto ilícito no autorizado como el acceso, alteración, destrucción, pérdida, o
divulgación de sus datos personales mientras son procesados (cada uno un "Incidente de seguridad"), ANCER
2023, S.A.P.I. DE C.V., llevará a cabo las siguientes acciones: le notificará de inmediato y sin demora sobre el
Incidente de Seguridad; investigará el Incidente de Seguridad y le proporcionará información detallada sobre el
mismo; y, tomará medidas razonables para mitigar los efectos y minimizar cualquier daño resultante de dicho
Incidente de Seguridad. Si Usted es nacional o residente de la Unión Europea, ANCER 2023, S.A.P.I. DE C.V.,
cumplirá con los requisitos del RGPD y tomará, las medidas inmediatas para notificar a la autoridad supervisora sin
demora y dentro de las 72 horas posteriores al descubrimiento del Incidente, si esto es posible. Sin embargo, lo
descrito en este párrafo no constituye reconocimiento por parte de ANCER 2023, S.A.P.I. DE C.V., sus accionistas,
administradores o demás empleados de responsabilidad alguna respecto a cualquier Incidente de Seguridad.
Recuerde que de acuerdo con el párrafo anterior no existe garantía alguna en caso de algún Incidente de Seguridad.
Monterrey, Nuevo León. México. Diciembre 21, 2023.""", // Tus términos y condiciones aquí.
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  child: Container(
                    color: Colors.white,
                    width: sizeH * 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(microseconds: 100),
                          margin: EdgeInsets.symmetric(horizontal: 24),
                          padding: EdgeInsets.only(top: currentPadding + 0),
                          width: double.maxFinite,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: Icon(
                                  Icons.close,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(
                                width: sizeH * 70,
                                child: Opacity(
                                  opacity: titleOpacity,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Aviso de Privacidad",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        "WhistleBlowwer",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w300),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.more_horiz,
                                color: Colors.grey[600],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 16),
                          width: double.maxFinite,
                          height: 1,
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 218, 218, 218),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 32,
                  child: Container(
                    width: 56,
                    height: 6,
                    decoration: BoxDecoration(
                        color: Color(0xFFE4E4E4),
                        borderRadius: BorderRadius.circular(24)),
                  ),
                ),
                Positioned(
                    bottom: 0,
                    child: Container(
                        height: sizeV * 14,
                        width: sizeH * 100,
                        decoration: const BoxDecoration(
                            gradient: LinearGradient(
                                tileMode: TileMode.repeated,
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                              Color.fromRGBO(238, 238, 238, 0),
                              Color.fromRGBO(238, 238, 238, 0.4),
                              Color.fromRGBO(238, 238, 238, 1)
                            ])),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            PressTransform(
                              onPressed: () {},
                              child: Container(
                                margin: EdgeInsets.only(
                                    right: sizeH * 5, left: sizeH * 5),
                                width: sizeH * 25,
                                height: sizeV * 7,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border:
                                        Border.all(color: Color(0xFFD6D6D6)),
                                    borderRadius: BorderRadius.circular(16)),
                                child: Text(
                                  "Cancelar",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            PressTransform(
                              onPressed: () {},
                              child: Container(
                                width: sizeH * 60,
                                height: sizeV * 7,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    gradient:
                                        GradientStyle().whistleBlowwerGradient,
                                    borderRadius: BorderRadius.circular(16)),
                                child: Text(
                                  "Aceptar",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'Montserrat',
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ))),
              ]),
            ),
          );
        },
      ),
    );
  }
}
