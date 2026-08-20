import 'package:flutter/material.dart';

//Colors

Color kPrimaryColor = const Color.fromARGB(255, 98, 3, 3);
Color grey = const Color(0xFF2C2B2B);
Color darkColor = const Color(0xFF040404);
Color lightColor = const Color(0xFFFFFFFF);

//Colors for signin page
// App Theme Colors

const Color kPrimaryColorColor =
    Color(0xFF8B0000); // A deep, rich maroon/dark red
const Color kBackgroundColor =
    Color(0xFF121212); // A very dark grey for the background
const Color kTextFieldFill =
    Color(0xFF1E1E1E); // Slightly lighter grey for text fields
const Color kAccentColor = Color(0xFFFFFFFF); // White for text and icons
const Color kGreyColor =
    Color(0xFFBDBDBD); // A standard grey for hints and secondary text

//Fonts

String primaryFont = 'Poppins';
String secondaryFonts = 'Proxima';
String subtitleFonts = 'Roboto';

//Fontsize

double boldTitle = 20;
double semiboldTitle = 18;
double textContent = 16;
double textSubTitle = 14;

//MoviesData List

List<Map<String, dynamic>> movieData = [
  {
    "title": "Bhool Bhulaiyaa 3",
    "imageUrl":
        "https://assets-in.bmscdn.com/iedb/movies/images/mobile/thumbnail/xlarge/bhool-bhulaiyaa-3-et00353996-1728474428.jpg",
    "bigPicture":
        "https://assets-in.bmscdn.com/iedb/movies/images/mobile/listing/xxlarge/bhool-bhulaiyaa-3-et00353996-1728474428.jpg",
    "rating": 4.0,
    "ratingCount": "92k",
    "metadata": "2h 38m • Comedy, Horror • UA • 1 Nov, 2024",
    "screenType": "2D",
    "language": "Hindi",
    "about":
        "Gear up to tickle your funny bones with some thrill. The gates of `haveli` will now open again for Bhool Bhulaiyaa 3!"
  },
  {
    "title": "Kanguva",
    "imageUrl":
        "https://assets-in.bmscdn.com/iedb/movies/images/mobile/thumbnail/xlarge/kanguva-et00357490-1711005979.jpg",
    "bigPicture":
        "https://assets-in.bmscdn.com/iedb/movies/images/mobile/listing/xxlarge/kanguva-et00357490-1711005979.jpg",
    "rating": 4.2,
    "ratingCount": "34k",
    "metadata":
        "2h 34m • Action, Adventure, Fantasy, Period • UA • 14 Nov, 2024",
    "screenType": "2D, ICE, ICE 3D, 3D, IMAX 2D, IMAX 3D",
    "language": "Tamil, Hindi, +3",
    "about":
        "Prepare to witness, epic emotions, raw rage, primal courage, ruthless revenge in its purest form."
  },
  {
    "title": "Amaran",
    "imageUrl":
        "https://assets-in.bmscdn.com/iedb/movies/images/mobile/thumbnail/xlarge/amaran-et00388085-1728627184.jpg",
    "bigPicture":
        "https://assets-in.bmscdn.com/iedb/movies/images/mobile/listing/xxlarge/amaran-et00388085-1728627184.jpg",
    "rating": 4.5,
    "ratingCount": "45k",
    "metadata": "2h 49m • Action, Drama, Thriller • UA • 31 Oct, 2024",
    "screenType": "2D",
    "language": "Tamil, Telugu, +3",
    "about":
        "Amaran is a true-life story of Major Mukund Varadarajan (Sivakarthikeyan), a commissioned officer in the Indian Army`s Rajput Regiment, who was posthumously awarded the Ashok Chakra for his valor during a counterterrorism operation while on deputation to the 44th Rashtriya Rifles battalion in Jammu and Kashmir."
  },
  {
    "title": "Venom: The Last Dance",
    "imageUrl":
        "https://assets-in.bmscdn.com/iedb/movies/images/mobile/thumbnail/xlarge/venom-the-last-dance-et00383474-1729596212.jpg",
    "bigPicture":
        "https://assets-in.bmscdn.com/iedb/movies/images/mobile/listing/xxlarge/venom-the-last-dance-et00383474-1729596212.jpg",
    "rating": 4.5,
    "ratingCount": "62k",
    "metadata": "1h 50m • Action, Adventure, Sci-Fi • UA • 24 Oct, 2024",
    "screenType": "2D, ICE, ICE 3D, 3D, IMAX 2D, IMAX 3D",
    "language": "Tamil, Hindi, +3",
    "about":
        "Eddie and Venom are on the run. Hunted by both of their worlds and with the net closing in, the duo are forced into a devastating decision that will bring the curtains down on Venom and Eddie`s last dance."
  },
  {
    "title": "The Wild Robot",
    "imageUrl":
        "https://assets-in.bmscdn.com/iedb/movies/images/mobile/thumbnail/xlarge/the-wild-robot-et00398665-1725532951.jpg",
    "bigPicture":
        "https://assets-in.bmscdn.com/iedb/movies/images/mobile/listing/xxlarge/the-wild-robot-et00398665-1725532951.jpg",
    "rating": 4.8,
    "ratingCount": "38k",
    "metadata": "21h 41m • Adventure, Animation, Family • U • 18 Oct, 2024",
    "screenType": "2D, ICE, ICE 3D, 3D, IMAX 2D, IMAX 3D",
    "language": "English, Hindi",
    "about":
        "Shipwrecked on a deserted island, a robot named Roz must learn to adapt to its new surroundings. Building relationships with the native animals, Roz soon develops a parental bond with an orphaned gosling."
  },
];

//Events list

List<String> eventImages = [
  'assets/images/amusement.png',
  'assets/images/r2.jpeg',
  'assets/images/comedy.png',
  'assets/images/games.png',
  'assets/images/kids.png',
  'assets/images/music.png',
];

//Premier moviedata

List<Map<String, dynamic>> premierMovieData = [
  {
    "title": "Glassmates",
    "imageUrl":
        "https://assets-in.bmscdn.com/iedb/movies/images/extra/vertical_logo/mobile/thumbnail/xxlarge/glassmates-et00372199-1730716676.jpg",
    "rating": 5.0,
    "ratingCount": "2.5k",
  },
  {
    "title": "Natpuna Ennanu Theriyuma",
    "imageUrl":
        "https://assets-in.bmscdn.com/iedb/movies/images/extra/vertical_logo/mobile/thumbnail/xxlarge/natpuna-ennanu-theriyuma-et00058078-1678779835.jpg",
    "rating": 5.0,
    "ratingCount": "2.4k",
  },
  {
    "title": "Kaaka Muttai",
    "imageUrl":
        "https://assets-in.bmscdn.com/iedb/movies/images/extra/vertical_logo/mobile/thumbnail/xxlarge/kaaka-muttai-et00025412-1728300154.jpg",
    "rating": 4.5,
    "ratingCount": "2.2k",
  },
  {
    "title": "Hostel",
    "imageUrl":
        "https://assets-in.bmscdn.com/iedb/movies/images/website/poster/large/hostel-et00327214-25-05-2022-02-16-59.jpg",
    "rating": 4.5,
    "ratingCount": "2.0k",
  },
  {
    "title": "Kaththi",
    "imageUrl":
        "https://assets-in.bmscdn.com/iedb/movies/images/website/poster/large/kaththi-et00023580-20-02-2021-06-29-11.jpg",
    "rating": 4.8,
    "ratingCount": "2.0k",
  },
  {
    "title": "Mission Chapter-1",
    "imageUrl":
        "https://assets-in.bmscdn.com/iedb/movies/images/website/poster/large/mission-chapter-1-et00382276-1710326350.jpg",
    "rating": 4.8,
    "ratingCount": "2.0k",
  },
  {
    "title": "Rasavathi",
    "imageUrl":
        "https://assets-in.bmscdn.com/iedb/movies/images/website/poster/large/rasavathi-et00397142-1718784969.jpg",
    "rating": 4.8,
    "ratingCount": "2.0k",
  },
];

//Cast Details

List<Map<String, dynamic>> castDetails = [
  {
    "name": "Vidya Balan",
    "imageUrl":
        "https://assets-in.bmscdn.com/iedb/artist/images/website/poster/large/vidya-balan-2457-14-09-2017-12-33-54.jpg",
    "role": "Mallika",
  },
  {
    "name": "Kartik Aaryan",
    "imageUrl":
        "https://in.bmscdn.com/iedb/artist/images/website/poster/large/kartik-aaryan-1045198-1685968467.jpg",
    "role": "Rooh Baba",
  },
  {
    "name": "Tripti Dimri",
    "imageUrl":
        "https://assets-in.bmscdn.com/iedb/artist/images/website/poster/large/tripti-dimri-1093177-01-06-2018-03-16-40.jpg",
    "role": "Kriti Singh",
  },
  {
    "name": "Madhuri Dixit",
    "imageUrl":
        "https://assets-in.bmscdn.com/iedb/artist/images/website/poster/large/madhuri-dixit-1318-29-09-2016-01-48-46.jpg",
    "role": "Mandira",
  },
  {
    "name": "Vijay Raaz",
    "imageUrl":
        "https://assets-in.bmscdn.com/iedb/artist/images/website/poster/large/vijay-raaz-2465-04-07-2018-12-40-58.jpg",
    "role": "Raja Saab",
  },
];

//Crew Details

List<Map<String, dynamic>> crewDetails = [
  {
    "name": "Anees Bazmee",
    "imageUrl":
        "https://assets-in.bmscdn.com/iedb/artist/images/website/poster/large/anees-bazmee-2651-19-09-2017-02-07-46.jpg",
    "role": "Director",
  },
  {
    "name": "Bhushan Kumar",
    "imageUrl":
        "https://assets-in.bmscdn.com/iedb/artist/images/website/poster/large/bhushan-kumar-1075903-11-11-2016-05-08-19.jpg",
    "role": "Producer",
  },
  {
    "name": "Krishan Kumar",
    "imageUrl":
        "https://assets-in.bmscdn.com/iedb/artist/images/website/poster/large/krishan-kumar-iein019780-24-03-2017-17-35-37.jpg",
    "role": "Producer",
  },
  {
    "name": "Tanishk Bagchi",
    "imageUrl":
        "https://assets-in.bmscdn.com/iedb/artist/images/website/poster/large/tanishk-bagchi-1067219-24-03-2017-16-26-34.jpg",
    "role": "Musician",
  },
  {
    "name": "Sanjay Sankla",
    "imageUrl":
        "https://assets-in.bmscdn.com/iedb/artist/images/website/poster/large/sanjay-sankla-iein010869-24-03-2017-15-03-41.jpg",
    "role": "Editor",
  },
];

//Date

List<Map<String, dynamic>> dateDetails = [
  {
    "date": "19",
    "day": "Tue",
    "month": "Nov",
  },
  {
    "date": "20",
    "day": "Wed",
    "month": "Nov",
  },
  {
    "date": "21",
    "day": "Fri",
    "month": "Nov",
  },
  {
    "date": "22",
    "day": "Sat",
    "month": "Nov",
  },
  {
    "date": "23",
    "day": "Sun",
    "month": "Nov",
  },
  {
    "date": "24",
    "day": "Mon",
    "month": "Nov",
  },
  {
    "date": "25",
    "day": "Tue",
    "month": "Nov",
  },
];

//Price Ranges

List<String> priceRange = [
  "0-100",
  "100-200",
  "200-300",
  "300-400",
  "400-500",
  "500-600",
  "600-700",
  "700-800",
  "800-900",
  "900-1000",
];

//Sghow Timings

List<String> showTimings = [
  "09:00 AM",
  "11:00 AM",
  "03:00 PM",
  "06:00 PM",
  "08:00 PM",
];

//Seat Options

List<Map<String, dynamic>> seatOptions = [
  {
    "number": 1,
    "image": "assets/images/bicycle.png",
  },
  {
    "number": 2,
    "image": "assets/images/bycicle.png",
  },
  {
    "number": 3,
    "image": "assets/images/autorickshaw.png",
  },
  {
    "number": 4,
    "image": "assets/images/car.png",
  },
  {
    "number": 5,
    "image": "assets/images/suv.png",
  },
];

// Genre List

List<Map<String, dynamic>> genres = [
  {"id": 28, "name": "Action"},
  {"id": 35, "name": "Comedy"},
  {"id": 18, "name": "Drama"},
  {"id": 27, "name": "Horror"},
  {"id": 10749, "name": "Romance"},
  {"id": 14, "name": "Fantasy"},
  {"id": 878, "name": "Sci-Fi"},
  {"id": 16, "name": "Animation"},
];
