# 1. 예약했고 왔는데 점유에 실패하는 경우
?- holder(X, Time, Room), is_present(X, Time), not(can_occupy(X, Time, Room)).

# 2. 허가되지 않은 사용자가 강의실을 점유할 수 있는가?
?- can_occupy(X, Time, Room), not(may_occupy(X, Time, Room)).

# 3. 방에 피해를 입힐 수 있는가?
?- can_harm(Time, Room).

# 4. 경비가 없고 휴일일 때 권한이 있는 사람이 점유할 수 있는가?
?- is_guard_absent(Time), can_occupy(X, Time, Room), may_occupy(X, Time, Room), holiday(Time).

# 5. 예약한 시간에 can_harm일 수 있는가? (전원이 자리를 비우면 안되는가?)
?- holder(X, Time, Room), can_harm(Time, Room).

# 6. 허가된 사용자가 점유할 수 없는 경우가 있는가?
?- guest(X, Time, Room), not(can_occupy(X, Time, Room)).
