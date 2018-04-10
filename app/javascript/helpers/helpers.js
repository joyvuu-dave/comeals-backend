export function generateTimes() {
    var times = [];
    var ending = "AM";

    for(var half = 0; half < 2; half++) {
      for(var hour = 0; hour < 12; hour++) {
        for(var min = 0; min < 2; min++) {

          // Start at 8am
          if(half === 0 && hour < 8) {
            continue;
          }

          // End at 10pm
          if(half === 1 && hour === 10 && min === 1) {
            return times;
          }

          var time = {
            display: null,
            value: null
          };

          var valueHour = hour;

          if(half === 1) {
            ending = "PM";
            valueHour += 12;
          }

          var minutes = `${(min * 30).toString().padStart(2, "0")}`;

          if(hour === 0) {
            time.display = `12:${minutes} ${ending}`;
          } else {
            time.display = `${hour}:${minutes} ${ending}`;
          }

          time.value = `${(valueHour).toString().padStart(2, "0")}:${minutes}`;

          times.push(time);
        }
      }
    }

    return times;
};
