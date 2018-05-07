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

export function getEventSources(community_id) {
  var host = `${window.location.protocol}//`;
  var topLevel = window.location.hostname.split(".");
  topLevel = `.${topLevel[topLevel.length - 1]}`;

  const EventSources = {
    all: [
      {
        url: `${host}api.comeals${topLevel}/api/v1/meals?community_id=${community_id}`,
        color: "#6699cc" // livid
      },
      {
        url: `${host}api.comeals${topLevel}/api/v1/bills?community_id=${community_id}`,
        color: "#444" // almost-black
      },
      {
        url: `${host}api.comeals${topLevel}/api/v1/rotations?community_id=${community_id}`
      },
      {
        url: `${host}api.comeals${topLevel}/api/v1/events?community_id=${community_id}`
      },
      {
        url: `${host}api.comeals${topLevel}/api/v1/guest-room-reservations?community_id=${community_id}`
      },
      {
        url: `${host}api.comeals${topLevel}/api/v1/common-house-reservations?community_id=${community_id}`
      },
      {
        url: `${host}api.comeals${topLevel}/api/v1/communities/${community_id}/birthdays?community_id=${community_id}`
      }
    ],
    birthdays: [
      {
        url: `${host}api.comeals${topLevel}/api/v1/communities/${community_id}/birthdays?community_id=${community_id}`
      }
    ],
    commonHouse: [
      {
        url: `${host}api.comeals${topLevel}/api/v1/common-house-reservations?community_id=${community_id}`
      }
    ],
    events: [
      {
        url: `${host}api.comeals${topLevel}/api/v1/events?community_id=${community_id}`
      }
    ],
    guestRoom: [
      {
        url: `${host}api.comeals${topLevel}/api/v1/guest-room-reservations?community_id=${community_id}`
      }
    ],
    meals: [
      {
        url: `${host}api.comeals${topLevel}/api/v1/meals?community_id=${community_id}`,
        color: "#6699cc" // livid
      },
      {
        url: `${host}api.comeals${topLevel}/api/v1/bills?community_id=${community_id}`,
        color: "#444" // almost-black
      },
      {
        url: `${host}api.comeals${topLevel}/api/v1/rotations?community_id=${community_id}`
      }
    ]
  };

  return EventSources;
}
