module Services
  class TuiParser < ApplicationService
    HOSTNAME = "https://www.tui.pl".freeze
    URL = "/api/services/tui-search/api/search/offers".freeze

    def call
      # params = {"childrenBirthdays":[],"departureDateFrom":"06.10.2025","departureDateTo":"24.10.2025","departuresCodes":["WMI"],"destinationsCodes":[],"durationFrom":6,"durationTo":8,"occupancies":[{"adultsCount":2,"childrenBirthDates":[],"participantsCount":2},{"adultsCount":2,"childrenBirthDates":[],"participantsCount":2},{"adultsCount":2,"childrenBirthDates":[],"participantsCount":2}],"numberOfAdults":6,"offerType":"BY_PLANE","site":"wypoczynek/wyniki-wyszukiwania-samolot?q=%3AcategoryDESC%3AbyPlane%3AT%3Aa%3AWMI%3AdF%3A6%3AdT%3A8%3AstartDate%3A06.10.2025%3AendDate%3A24.10.2025%3ActAdult%3A6%3ActChild%3A0%3Aroom%3A2%3Aroom%3A2%3Aroom%3A2%3AamountRange%3A%252318000%3AminHotelCategory%3AdefaultHotelCategory%3AtripAdvisorRating%3AdefaultTripAdvisorRating%3Abeach_distance%3AdefaultBeachDistance%3AtripType%3AWS&fullPrice=false","filters":[{"filterId":"priceSelector","selectedValues":[]},{"filterId":"board","selectedValues":[]},{"filterId":"amountRange","selectedValues":["#18000"]},{"filterId":"minHotelCategory","selectedValues":["defaultHotelCategory"]},{"filterId":"flight_category","selectedValues":[]},{"filterId":"tripAdvisorRating","selectedValues":["defaultTripAdvisorRating"]},{"filterId":"beach_distance","selectedValues":["defaultBeachDistance"]},{"filterId":"facilities","selectedValues":[]},{"filterId":"WIFI","selectedValues":[]},{"filterId":"sport_and_wellness","selectedValues":[]},{"filterId":"room_type","selectedValues":[]},{"filterId":"room_attributes","selectedValues":[]},{"filterId":"hotel_chain","selectedValues":[]},{"filterId":"airport_distance","selectedValues":[]}],"metaData":{"page":0,"pageSize":10000,"sorting":"categoryDESC"}}
      allin = { "childrenBirthdays": [], "departureDateFrom": "06.10.2025", "departureDateTo": "24.10.2025", "departuresCodes": [ "WMI" ], "destinationsCodes": [], "durationFrom": 6, "durationTo": 8, "occupancies": [ { "adultsCount": 2, "childrenBirthDates": [], "participantsCount": 2 }, { "adultsCount": 2, "childrenBirthDates": [], "participantsCount": 2 }, { "adultsCount": 2, "childrenBirthDates": [], "participantsCount": 2 } ], "numberOfAdults": 6, "offerType": "BY_PLANE", "site": "wypoczynek/wyniki-wyszukiwania-samolot?q=%3AcategoryDESC%3AbyPlane%3AT%3Aa%3AWMI%3AdF%3A6%3AdT%3A8%3AstartDate%3A06.10.2025%3AendDate%3A24.10.2025%3ActAdult%3A6%3ActChild%3A0%3Aroom%3A2%3Aroom%3A2%3Aroom%3A2%3Aboard%3AGT06-AI%2520GT06-XX%3AamountRange%3A%252318000%3AminHotelCategory%3AdefaultHotelCategory%3AtripAdvisorRating%3AdefaultTripAdvisorRating%3Abeach_distance%3AdefaultBeachDistance%3AtripType%3AWS&fullPrice=false", "filters": [ { "filterId": "priceSelector", "selectedValues": [] }, { "filterId": "board", "selectedValues": [ "GT06-AI GT06-XX" ] }, { "filterId": "amountRange", "selectedValues": [ "#18000" ] }, { "filterId": "minHotelCategory", "selectedValues": [ "defaultHotelCategory" ] }, { "filterId": "flight_category", "selectedValues": [] }, { "filterId": "tripAdvisorRating", "selectedValues": [ "defaultTripAdvisorRating" ] }, { "filterId": "beach_distance", "selectedValues": [ "defaultBeachDistance" ] }, { "filterId": "facilities", "selectedValues": [] }, { "filterId": "WIFI", "selectedValues": [] }, { "filterId": "sport_and_wellness", "selectedValues": [] }, { "filterId": "room_type", "selectedValues": [] }, { "filterId": "room_attributes", "selectedValues": [] }, { "filterId": "hotel_chain", "selectedValues": [] }, { "filterId": "airport_distance", "selectedValues": [] } ], "metaData": { "page": 0, "pageSize": 10000, "sorting": "categoryDESC" } }

      conn = Faraday.new(
        url: HOSTNAME,
        headers: { "Content-Type" => "application/json", 'Accept': "application/json" }
      )

      res = conn.post(URL) do |req|
        req.body = allin.to_json
      end

      data = JSON.parse(res.body)
      data["offers"].map do |d|
        # puts d["breadcrumbs"].map {|x| x["label"]}.join(" - ")
        # puts "#{d["discountPerPersonPrice"]}zł/os"
        # puts "#{d["departureTime"]} #{d["departureDate"]} - #{d["returnDate"]} #{d["returnTime"]}"
        # puts "Wylot: #{d["departureAirport"]}"
        # puts "Rating: #{d["tripAdvisorRating"]}/5 L.ocen: #{d["tripAdvisorReviewsNo"]}"
        # puts "Standard #{'★'*d["hotelStandard"].to_i}#{'☆'*(5- d["hotelStandard"].to_i)}"
        # puts "#{d["boardType"]}"
        # # puts "#{}"
        # puts "Oferta: https://www.tui.pl#{d["offerUrl"]}"
        # puts ""
        {
          country: d["breadcrumbs"][0]["label"],
          city: d["breadcrumbs"][1]["label"],
          region: d["breadcrumbs"][2]&.fetch("label"),
          price: d["discountPerPersonPrice"],
          airport: d["departureAirport"],
          departure: "#{d["departureTime"]} #{d["departureDate"]}",
          return: d["returnDate"],
          trip_advisor_rating: d["tripAdvisorRating"],
          trip_advisor_reviews: d["tripAdvisorReviewsNo"],
          standard: d["hotelStandard"].to_i,
          type: d["boardType"],
          url: "https://www.tui.pl#{d["offerUrl"]}"
        }
      end
    end
  end
end
