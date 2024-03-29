# Global Variables

lat = 42.3581
long = 71.0636
district = "MA - 5"
state = ""
sunlight_api = "&apikey=0fef72b6b209410ba414e58468bb70f5"
goog_api = "AIzaSyDHEs7hFRiVb3BovLC4rMRvg1wbwsyc678"
abbrev_to_full = {'WA': 'Washington', 'DE': 'Delaware', 'DC': 'District of Columbia', 'WI': 'Wisconsin', 'WV': 'West Virginia', 'HI': 'Hawaii', 'FL': 'Florida', 'WY': 'Wyoming', 'NH': 'New Hampshire', 'NJ': 'New Jersey', 'NM': 'New Mexico', 'TX': 'Texas', 'LA': 'Louisiana', 'AK': 'Alaska', 'NC': 'North Carolina', 'ND': 'North Dakota', 'NE': 'Nebraska', 'TN': 'Tennessee', 'NY': 'New York', 'PN': 'Pennsylvania', 'RI': 'Rhode Island', 'NV': 'Nevada', 'VA': 'Virginia', 'CO': 'Colorado', 'CA': 'California', 'AL': 'Alabama', 'AR': 'Arkansas', 'VT': 'Vermont', 'IL': 'Illinois', 'GA': 'Georgia', 'IN': 'Indiana', 'IA': 'Iowa', 'MA': 'Massachusetts', 'AZ': 'Arizona', 'ID': 'Idaho', 'CT': 'Connecticut', 'ME': 'Maine', 'MD': 'Maryland', 'OK': 'Oklahoma', 'KE': 'Kentucky', 'OH': 'Ohio', 'UT': 'Utah', 'MO': 'Missouri', 'MN': 'Minnesota', 'MI': 'Michigan', 'KS': 'Kansas', 'MT': 'Montana', 'MS': 'Mississippi', 'SC': 'South Carolina', 'OR': 'Oregon', 'SD': 'South Dakota'}


# dem_vals = {}
# rep_vals = {}


get_location = () ->
    if navigator.geolocation
        navigator.geolocation.getCurrentPosition(make_regional)
    else
        console.log("Geolocation is not supported by this browser.")


make_regional = (location) ->

    lat = location.coords.latitude
    long = location.coords.longitude
    district_url = "https://congress.api.sunlightfoundation.com/districts/locate?"

    d3.json(district_url + "latitude=" + String(lat) + "&longitude=" + String(long) + sunlight_api, (error, json) ->
        if error
            console.log("fail")
        state = json.results[0].state 

        district = String(state + " - " + json.results[0].district)
        $(".location").text(" " + district)
        d3.select("#content_head").text(district)
        prev_results(state)
        # get_state_legs(lat, long, state)
        )
    get_legislators(lat, long)
    


get_legislators = (lat, long) -> 

    legislators_url = "https://congress.api.sunlightfoundation.com/legislators/locate?"

    d3.json(legislators_url + "latitude=" + String(lat) + "&longitude=" + String(long) + sunlight_api, (error, json) ->
        if error
            console.log("fail")
        process_legislators(json['results'])
    )

process_legislators = (leg_list) ->

    legs = ''

    # make the table elements
    template = _.template("<tr><td><%-title%>. <%-first_name%> <%-last_name%> (<%-party%>)</td><td>@<%-twitter_id%></td><td><%-office%></td><td><%-website%></td><td><%-term_end%></td><tr>")

    for item in leg_list
        legs += String(template(item))

    # append to table 
    d3.select("#leg_table").append("tbody").attr("id", "table_bod").html(legs)

    # Add tooltip to twitter and rep page
    d3.selectAll("td:nth-child(4)")
    .on("click", (d) ->
        window.location.href = $(this).html();
        )
    .attr("title", "Click to Go to Member Page")
    
    d3.selectAll("td:nth-child(2)")
    .on("click", (d) ->
        twitter = $(this).html()
        window.location.href = 'https://twitter.com/' + twitter.substring(1, twitter.length);
        )
    .attr("title", "Click to Go to Member Twitter Page")

search_location = (location) -> 
    console.log("here")

prev_results = (state) ->
    # console.log("hey")
    # $("#search_form").submit (val) ->

    #     console.log($("#search_input").val())

    #     search_location($("#search_input").val())

    #     return false

    d3.select("#results").append("h1").text(abbrev_to_full[state])
    d3.json("/maps/" + String(state), (error, data) ->

        if error
            return console.error(error)
        
        stats = data["data"]
        console.log(state)
        d3.select("#results").append("h4").text(String("Obama Percent of Votes: " + stats[0] + "%"))
        d3.select("#results").append("h4").text(String("Obama Total Votes: " + stats[1]))
        d3.select("#results").append("h4").text(String("Romney Percent of Votes: " + stats[2] + "%"))
        d3.select("#results").append("h4").text(String("Romney Total Votes: " + stats[3]))
        d3.select("#results").append("h4").text(String("Percent of Votes for Other Candidates: " + stats[4] + "%"))
        )

    # d3.json("/maps/rep_rank", (error, data) ->

    #     if error 
    #         return console.error(error)
    #     rep_vals = data
    #     d3.select("#results").append("h4").text(String("Romney: " + rep_vals[state]+ "%"))

    #     )
    

$(document).ready(() ->
    $(document).tooltip()

    
    get_location()

    )










