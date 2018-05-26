import Cookie from "js-cookie";

export function generateTimes() {
  var times = [];
  var ending = "AM";

  for (var half = 0; half < 2; half++) {
    for (var hour = 0; hour < 12; hour++) {
      for (var min = 0; min < 2; min++) {
        // Start at 8am
        if (half === 0 && hour < 8) {
          continue;
        }

        // End at 10pm
        if (half === 1 && hour === 10 && min === 1) {
          return times;
        }

        var time = {
          display: null,
          value: null
        };

        var valueHour = hour;

        if (half === 1) {
          ending = "PM";
          valueHour += 12;
        }

        var minutes = `${(min * 30).toString().padStart(2, "0")}`;

        if (hour === 0) {
          time.display = `12:${minutes} ${ending}`;
        } else {
          time.display = `${hour}:${minutes} ${ending}`;
        }

        time.value = `${valueHour.toString().padStart(2, "0")}:${minutes}`;

        times.push(time);
      }
    }
  }

  return times;
}

export function getCalendarInfo(community_id, calendar_type) {
  var host = `${window.location.protocol}//`;
  var topLevel = window.location.hostname.split(".");
  topLevel = `.${topLevel[topLevel.length - 1]}`;

  let result = {
    eventSources: [],
    displayName: ""
  };

  switch (calendar_type) {
    case "all":
      result.eventSources = [
        {
          url: `${host}api.comeals${topLevel}/api/v1/meals?community_id=${community_id}&token=${Cookie.get(
            "token"
          )}`,
          color: "#6699cc" // livid
        },
        {
          url: `${host}api.comeals${topLevel}/api/v1/bills?community_id=${community_id}&token=${Cookie.get(
            "token"
          )}`,
          color: "#444" // almost-black
        },
        {
          url: `${host}api.comeals${topLevel}/api/v1/rotations?community_id=${community_id}&token=${Cookie.get(
            "token"
          )}`
        },
        {
          url: `${host}api.comeals${topLevel}/api/v1/events?community_id=${community_id}&token=${Cookie.get(
            "token"
          )}`
        },
        {
          url: `${host}api.comeals${topLevel}/api/v1/guest-room-reservations?community_id=${community_id}&token=${Cookie.get(
            "token"
          )}`
        },
        {
          url: `${host}api.comeals${topLevel}/api/v1/common-house-reservations?community_id=${community_id}&token=${Cookie.get(
            "token"
          )}`
        },
        {
          url: `${host}api.comeals${topLevel}/api/v1/communities/${community_id}/birthdays?community_id=${community_id}&token=${Cookie.get(
            "token"
          )}`
        }
      ];
      result.displayName = "ALL";
      break;

    case "birthdays":
      result.eventSources = [
        {
          url: `${host}api.comeals${topLevel}/api/v1/communities/${community_id}/birthdays?community_id=${community_id}&token=${Cookie.get(
            "token"
          )}`
        }
      ];
      result.displayName = "BIRTHDAYS";
      break;

    case "common-house":
      result.eventSources = [
        {
          url: `${host}api.comeals${topLevel}/api/v1/common-house-reservations?community_id=${community_id}&token=${Cookie.get(
            "token"
          )}`
        }
      ];
      result.displayName = "COMMON HOUSE";
      break;

    case "events":
      result.eventSources = [
        {
          url: `${host}api.comeals${topLevel}/api/v1/events?community_id=${community_id}&token=${Cookie.get(
            "token"
          )}`
        }
      ];
      result.displayName = "EVENTS";
      break;

    case "guest-room":
      result.eventSources = [
        {
          url: `${host}api.comeals${topLevel}/api/v1/guest-room-reservations?community_id=${community_id}&token=${Cookie.get(
            "token"
          )}`
        }
      ];
      result.displayName = "GUEST ROOM";
      break;

    case "meals":
      result.eventSources = [
        {
          url: `${host}api.comeals${topLevel}/api/v1/meals?community_id=${community_id}&token=${Cookie.get(
            "token"
          )}`,
          color: "#6699cc" // livid
        },
        {
          url: `${host}api.comeals${topLevel}/api/v1/bills?community_id=${community_id}&token=${Cookie.get(
            "token"
          )}`,
          color: "#444" // almost-black
        },
        {
          url: `${host}api.comeals${topLevel}/api/v1/rotations?community_id=${community_id}&token=${Cookie.get(
            "token"
          )}`
        }
      ];
      result.displayName = "MEALS";
      break;
  }

  return result;
}
