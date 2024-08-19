import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';

const String API_KEY = 'OPENWEATHERMAP API';

void main() {
  runApp(HavaDurumuUygulamasi());
}

class HavaDurumuUygulamasi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HavaDurumuGorunumu(),
    );
  }
}

class HavaDurumuGorunumu extends StatefulWidget {
  @override
  _HavaDurumuGorunumuState createState() => _HavaDurumuGorunumuState();
}

class _HavaDurumuGorunumuState extends State<HavaDurumuGorunumu> {
  double? sicaklik;
  String? aciklama;
  String? simdikiHavaDurumu;
  String? sehirAdi;
  String? icon;
  int? nem;
  double? ruzgarHizi;

  @override
  void initState() {
    super.initState();
    havaDurumunuAl();
  }

  Future<void> havaDurumunuAl() async {
    Position konum = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    koordinatlardanHavaDurumunuGuncelle(konum.latitude, konum.longitude);
  }

  void sehirAdindanHavaDurumunuGuncelle(String sehirAdi) async {
    try {
      final yanit = await http.get(Uri.parse(
          'http://api.openweathermap.org/data/2.5/weather?q=$sehirAdi&units=metric&appid=$API_KEY&lang=tr'));
      if (yanit.statusCode == 200) {
        var sonuclar = jsonDecode(yanit.body);
        setState(() {
          this.sicaklik = sonuclar['main']['temp'];
          this.aciklama = sonuclar['weather'][0]['description'];
          this.simdikiHavaDurumu = sonuclar['weather'][0]['main'];
          this.sehirAdi = sonuclar['name'];
          this.icon = sonuclar['weather'][0]['icon'];
          this.nem = sonuclar['main']['humidity'];
          this.ruzgarHizi = sonuclar['wind']['speed'];
        });
      } else {
        print(
            'Hava durumu verisi yüklenemedi. Durum Kodu: ${yanit.statusCode}. Yanıt: ${yanit.body}');
      }
    } catch (e) {
      print('Bir hata oluştu: $e');
    }
  }

  void koordinatlardanHavaDurumunuGuncelle(double enlem, double boylam) async {
    try {
      final yanit = await http.get(Uri.parse(
          'http://api.openweathermap.org/data/2.5/weather?lat=$enlem&lon=$boylam&units=metric&appid=$API_KEY&lang=tr'));
      if (yanit.statusCode == 200) {
        var sonuclar = jsonDecode(yanit.body);
        setState(() {
          this.sicaklik = sonuclar['main']['temp'];
          this.aciklama = sonuclar['weather'][0]['description'];
          this.simdikiHavaDurumu = sonuclar['weather'][0]['main'];
          this.sehirAdi = sonuclar['name'];
          this.icon = sonuclar['weather'][0]['icon'];
          this.nem = sonuclar['main']['humidity'];
          this.ruzgarHizi = sonuclar['wind']['speed'];
        });
      } else {
        print(
            'Hava durumu verisi yüklenemedi. Durum Kodu: ${yanit.statusCode}. Yanıt: ${yanit.body}');
      }
    } catch (e) {
      print('Bir hata oluştu: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        title: Text("Hava Durumu Uygulaması"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  String aramaSorgusu = '';
                  return AlertDialog(
                    title: Text('Bir şehir arayın'),
                    content: TextField(
                      onChanged: (deger) {
                        aramaSorgusu = deger;
                      },
                      decoration: InputDecoration(hintText: "Şehir adı"),
                    ),
                    actions: [
                      TextButton(
                        child: Text('Ara'),
                        onPressed: () {
                          sehirAdindanHavaDurumunuGuncelle(aramaSorgusu);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'Konum: $sehirAdi',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          String aramaSorgusu = '';
                          return AlertDialog(
                            title: Text('Bir şehir arayın'),
                            content: TextField(
                              onChanged: (deger) {
                                aramaSorgusu = deger;
                              },
                              decoration: InputDecoration(hintText: "Şehir adı"),
                            ),
                            actions: [
                              TextButton(
                                child: Text('Ara'),
                                onPressed: () {
                                  sehirAdindanHavaDurumunuGuncelle(aramaSorgusu);
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Image.network(
                  'http://openweathermap.org/img/w/$icon.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Card(
                child: ListTile(
                  leading: Icon(Icons.thermostat_outlined),
                  title: Text(
                    'Sıcaklık: $sicaklik °C',
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Card(
                child: ListTile(
                  leading: Icon(Icons.cloud),
                  title: Text(
                    'Genel Hava Durumu: $simdikiHavaDurumu',
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Card(
                child: ListTile(
                  leading: Icon(Icons.article_outlined),
                  title: Text(
                    'Açıklama: $aciklama',
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Card(
                child: ListTile(
                  leading: Icon(Icons.opacity),
                  title: Text(
                    'Nem: %$nem',
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Card(
                child: ListTile(
                  leading: Icon(Icons.waves_outlined),
                  title: Text(
                    'Rüzgar Hızı: $ruzgarHizi m/s',
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
