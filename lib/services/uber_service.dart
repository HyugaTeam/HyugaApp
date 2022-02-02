import 'package:http/http.dart' as http;

class UberService {
  getRide() async{
    
    final req = await http.post(Uri(path: "https://login.uber.com/oauth/v2/token"),
    headers: {
      "client_secret": "QHpMDhURp4wOe3A9fP5pjiyNeRayQJykd6GlXdu-",
      "client_id": "LNvSpVc4ZskDaV1rDZe8hGZy02dPfN84",
      "grant_type": "authorization_code",
      "redirect_uri": "https://www.hyuga.ro/",
      "code": "JA.VUNmGAAAAAAAEgASAAAABwAIAAwAAAAAAAAAEgAAAAAAAAH4AAAAFAAAAAAADgAQAAQAAAAIAAwAAAAOAAAAzAAAABwAAAAEAAAAEAAAAMT5PXDDut-7w_xwFyCUGG2nAAAAYNvXzElo-C0OSsravy2aiF-TSnWllvBlQziVeudZxTmjCSRb7iws6TvEZXHXs_q0lCNIGPS7QasEhMWpfV4ZGaIClqf5RkXRRlDLjvmYoSd8K4CumFhOmiBkxtjYwBfgDYSkvi7V1Ka1vTuESByYlZrCk6vKvB8nkPWM4PDt-9L4RsOjvGP8Rd4piBtWTTGL2_7YzfoANobF53SGHpGi2RIcjA7-C0MADAAAAI_xXb_XwnItqlF44iQAAABiMGQ4NTgwMy0zOGEwLTQyYjMtODA2ZS03YTRjZjhlMTk2ZWU"
    });
    print(req.body);

    final req1 = await http.get(Uri(path: "https://api.uber.com/v1.2/estimates/price?latitude=37.7752315&longitude=-122.418075"),
      headers: {
        "Authorization": "JA.VUNmGAAAAAAAEgASAAAABwAIAAwAAAAAAAAAEgAAAAAAAAH4AAAAFAAAAAAADgAQAAQAAAAIAAwAAAAOAAAAzAAAABwAAAAEAAAAEAAAABn5WZG2SOjO3z3Y2WR_ggOnAAAATIQqKeRQxvICqcdj29X95jAOyfnISypDB6a-ZtNwOxr2Iy8TeJrmbVWhLqf5FyyYwy1v6KJODvs98XIWZ7bs4n3VHeA6XfVmXaKy-ypWiZiu1QmNdlbCt6KlB8XtsJ62mfMAOaBOtAYeVb-c2KnkSYyoWOnzZ_CP_euzRGnLU1JQk-T30kmzeg6reQ_M7W3THA4X74hJ8QTuxAf2JJRs3XgCYbweCD8ADAAAABXfmJ46l7KBaEHkZiQAAABiMGQ4NTgwMy0zOGEwLTQyYjMtODA2ZS03YTRjZjhlMTk2ZWU",
        "Content-Type": "application/json",
        "Accept-Language": "en_US"
      }
    );
    print(req1.body);
    
  }
}