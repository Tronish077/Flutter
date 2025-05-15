import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MaterialApp(
  theme: ThemeData(
    fontFamily: 'bahnschrift',
  ),
  home : Home()
));

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

 final apiKey = "016ae16eba35cd874e25876fe711b8ec";
 dynamic receivedData;
 dynamic FlagPic;
 bool loading = false;
 dynamic cloudSrc = "";
 dynamic bgName = "";

 //Elements List
 List elementList = [
   {"name":"Wind",
     "link":"assets/defaultWind.png",
     "measure":"- m/s"},
   {
     "name":"Humidity",
     "link":"assets/defaultHumid.png",
     "measure":" - %"
   },
   { "name":"Pressure",
     "link":"assets/defaultPress.png",
     "measure":" - hpa"
   },
   { "name":"Sea-Level",
     "link":"assets/defaultSea.png",
     "measure":" - hPa"
   }
 ];

 //Set Bg and cloudImg
 void setCloudImg(arr){
      setState(() {
        bgName = arr[1];
        cloudSrc = arr[0];
      });
 }

 //Get weather emoji 🔥
 void getWeatherEmoji(dynamic id) {
   int weatherId = id is String ? int.parse(id) : id;

   if (weatherId >= 200 && weatherId < 300) {
     setCloudImg(["assets/thunderstorm-98541_1280.png", "assets/thunderstorm.jpg"]);
   } else if (weatherId >= 300 && weatherId < 400) {
     setCloudImg(["assets/lighrVec.png", "assets/jjj.jpg"]);
   } else if (weatherId >= 500 && weatherId < 600) {
     setCloudImg(["assets/lighrVec.png", "assets/rainnsun.jpg"]);
   } else if ((weatherId >= 600 && weatherId < 700) || receivedData.temp <= 0) {
     // temp is in Kelvin, 273.15 = 0°C
     setCloudImg(["assets/snowvec.png", "assets/snowwy.jpg"]);
   } else if (weatherId >= 700 && weatherId < 800) {
     setCloudImg(["assets/cloudvec.png", "assets/jjj.jpg"]);
   } else if (weatherId == 800) {
     setCloudImg(["assets/sunvec.png", "assets/sunny.jpg"]);
   } else if (weatherId > 800 && weatherId <= 804) {
     setCloudImg(["assets/cloudvec.png", "assets/rainnsun.jpg"]);
   } else {
     setCloudImg(["assets/sunvec.png", "assets/sunny.jpg"]);
   }

 }

 //Editing Controller
 TextEditingController Search = TextEditingController();
 String searchPlace = "";

 void showLoadingDialog(BuildContext context){
   showDialog(context: context,
       barrierDismissible: false,
       builder: (BuildContext context){
          return AlertDialog(
              elevation: 5,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
            ),
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 40),
                Text("Getting Weather Data ... ")
              ],
            ),
          );
       });
 }

 //GetWeather Data
 Future getWeatherData(value) async{
   var apiQuery = Uri.parse("https://api.openweathermap.org/data/2.5/weather?q=${value.trim()}&appid=$apiKey");
   var apiFetch = await http.get(apiQuery);
   var data = json.decode(apiFetch.body);

   if(data['cod'] != 404){
   setState(() {
     receivedData = WeatherData.fromJson(data);
     getWeatherEmoji(receivedData.weatherId);
     Search.text = "";
   });
   }
       return data;
 }

 evaluateSearch(value,context)async{
   if (value.isEmpty){
     ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text(
             "Please Enter A valid location !!",
             style: TextStyle(color: Colors.white),
           ),
           backgroundColor: Colors.red,
           duration: Duration(seconds: 2),
           behavior: SnackBarBehavior.floating,
         )
     );
   }
   else{
     try {
       print(value);
       showLoadingDialog(context);
       var weathVAl = await getWeatherData(value);
       Navigator.pop(context);

       if(weathVAl['cod'] == 400){
         Navigator.pop(context);
         ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Row(
                 children: [
                   Icon(Icons.error,color: Colors.white),
                   Text(
                       "Location Not Found",
                       style: TextStyle(
                           color:Colors.white
                       )
                   ),
                 ],
               ),
               behavior: SnackBarBehavior.floating,)
         );
       }
     }catch(e){
       Navigator.pop(context);
       print(e);
       ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             backgroundColor: Colors.red,
             content: Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Icon(Icons.error,color: Colors.white),
                 SizedBox(width: 15),
                 Text("Location Not Found",
                     style: TextStyle(color: Colors.white,
                         fontWeight: FontWeight.bold )
                 ),
               ],
             ),
             behavior: SnackBarBehavior.floating,
           )
       );
     }
   }
 }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Color.fromARGB(255, 1, 10, 33),
      body:
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: receivedData != null && receivedData is WeatherData && bgName != "" ?
                  AssetImage(bgName) : AssetImage('assets/defaultBG.jpeg'),
                  fit: BoxFit.cover
                )
              ),
            ),BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8,sigmaY: 8),
              child: Container(
                color: Colors.black.withOpacity(0.12),
              ),
            ),
            SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical:40),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: const Color.fromARGB(61, 205, 211, 216),
                                borderRadius: BorderRadius.circular(6)
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: Search,
                                    keyboardType: TextInputType.webSearch,
                                    style: TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      hintText: "Search Your Location",
                                      hintStyle: TextStyle(color: Colors.white60),

                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide.none
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                         borderSide : BorderSide(color:Colors.white),

                                      ),
                                    ),
                                    onSubmitted: (value) async{
                                      setState(() {
                                        searchPlace = Search.text;
                                      });
                                      await evaluateSearch(value, context);
                                    },
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async{
                                    setState(() {
                                      searchPlace = Search.text;
                                    });
                                      await evaluateSearch(searchPlace, context);
                                },
                                  icon: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: const Color.fromARGB(63, 255, 255, 255),
                                    ),
                                    child: Icon(
                                        Icons.find_replace_outlined,
                                        color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height:20),
                          //Location 📍
                          Column(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  receivedData != null && receivedData is WeatherData ?
                                  Image.network("https://flagsapi.com/${receivedData.country}/flat/32.png")
                                      : Image.asset('assets/defaultFlag.png',width: 20,height: 20,),
                                  Text(receivedData != null && receivedData is WeatherData ?
                                  "${receivedData.city}, ${receivedData.country}" : "No Location Set !!!"
                                    ,style: TextStyle(color:Colors.white,fontSize: 28),),
                                  SizedBox(height: 20),
                                  Text( receivedData != null && receivedData is WeatherData ?
                                  "${receivedData.desc}":
                                  "-"
                                      ,style:TextStyle(
                                          color: Colors.white,fontSize: 15
                                      )),
                                ],
                              ),
                              SizedBox(height: 30),
                              //Temperature Section To Wind 💨🍃🌬️
                              //Cloud Image 😶‍🌫️🔴
                                receivedData != null && receivedData is WeatherData && cloudSrc != "" ?
                                    Image.asset(cloudSrc,
                                      height: 120,
                                      width: 120,) : Image.asset(
                                  "assets/defaultCloud.png",
                                  height: 90,
                                  width: 90,
                                ),
                              SizedBox(height:10),
                              //Weather Number 🔷🔴
                              Text(receivedData != null && receivedData is WeatherData ?
                              "${receivedData.temp}°" : "-°"
                                  ,style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 80
                                  ),textAlign: TextAlign.center),
                              SizedBox(height: 15),
                              //Feels like Part
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset('assets/defaultTemp.png',
                                    height: 20,width: 20,),
                                  SizedBox(height: 10),
                                  Text(receivedData != null && receivedData is WeatherData ?
                                  "Feels Like ${receivedData.feelsLike}°C":
                                  "-°C"
                                      ,style:TextStyle(
                                          color: Colors.white,fontSize: 18
                                      )
                                  )
                                ],
                              ),
                              SizedBox(height: 50),
                              Container(
                                  decoration: BoxDecoration(
                                    // color: const Color.fromARGB(255, 5, 33, 100),
                                      borderRadius: BorderRadius.circular(8)
                                  ),
                                  child: Wrap(
                                    spacing: 4,
                                      runSpacing: 20,
                                      runAlignment: WrapAlignment.center,
                                      children: elementList.map(
                                              (ele)=>(
                                              tableEntries(eleName: ele["name"],
                                                  iconLink: ele['link'],
                                                  measurement:
                                                  receivedData != null && receivedData is WeatherData ?
                                                  getMeasurement(ele["name"], receivedData) :
                                                  " - "
                                              )
                                          )
                                      ).toList()
                                  )
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
          ]
        )
    );
 }
}

class WeatherData {
  String city = "";
  String country = "";
  int temp = 0;
  int feelsLike = 0;
  String desc = "";
  int wind = 0;
  int humidity = 0;
  int pressure = 0;
  int sea_level = 0;
  int weatherId = 0;

  WeatherData({
    required this.city,
    required this.country,
    required this.temp,
    required this.feelsLike,
    required this.desc,
    required this.wind,
    required this.humidity,
    required this.pressure,
    required this.sea_level,
    required this.weatherId
  });

  factory WeatherData.fromJson(Map<String, dynamic> json){
    return WeatherData(
        city: json['name'],
        country: json['sys']['country'],
        temp: (json['main']['temp'] - 273.15).round(),
        feelsLike: (json['main']['feels_like'] - 273.15).round(),
        desc: json['weather'][0]['description'],
        wind: (json['wind']['speed'] as num).round(),
        humidity: json['main']['humidity'],
        pressure: json['main']['pressure'],
        sea_level: json['main']['sea_level'] ?? json['main']['grnd_level'] ?? 0,
        weatherId: json['weather'][0]['id']
    );
  }
}

String getMeasurement(String name, WeatherData data) {
  switch (name) {
    case "Wind":
      return "${data.wind} m/s";
    case "Humidity":
      return "${data.humidity} %";
    case "Pressure":
      return "${data.pressure} hPa";
    case "Sea-Level":
      return "${data.sea_level} hPa";
    default:
      return "-";
  }
}

Widget tableEntries({eleName,iconLink,measurement}){
  return  Container(
    height: 120,
    width: 87,
    decoration: BoxDecoration(
      color: const Color.fromARGB(117, 59, 63, 60),
      borderRadius: BorderRadius.circular(20)
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                  '$iconLink',
                  height: 38,width: 38
              ),SizedBox(height: 8,),
              Text("$eleName",style: TextStyle(
                  color: Colors.white70
              ),),SizedBox(height:12),
                  Text("$measurement",style:
                  TextStyle(
                      color: Colors.white,
                      fontSize: 17
                  ),)
                ],
              )
      ],
    )
        );
}

