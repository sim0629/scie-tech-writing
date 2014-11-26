/* 도메인 정의 */
guard(g1).
normal(jaechan).
normal(gyumin).
normal(seulgi).
normal(jaesung).
normal(chanmin).
human(P) :- guard(P);normal(P).
/* 요일을 의미하는 것이 아니라 강의실을 예약할 수 있는 특정 시간 범위이다 */
timeseg(sat).
timeseg(sun).
timeseg(mon).
timeseg(tue).
timeseg(wed).
timeseg(thu).
timeseg(fri).
room(r301).
room(r302).
room(r303).
room(r304).
room(r305).
holiday(sat).
holiday(sun).

/* any combination that is not holder */
/* if X is holder of Room on Time then, X is not not holder of Room on Time. */
not_holder(X, Time, Room) :- normal(X), timeseg(Time), room(Room), \+ holder(X, Time, Room).

/* the condition that should be satisfied for invite */
/* if X invited someone, then X should be the holder of the room, otherwise fail. */
/* !, fail. 은 존재의 부정을 의미한다. 즉 앞 predicate가 true가 되면 즉시 탐색을 멈추고, false*/
invite(X, _, Time, Room) :- not_holder(X, Time, Room), !, fail.
guest(X, Time, Room) :- holder(Y, Time, Room), invite(Y, X, Time, Room). /* common */

is_absent(P, Time) :- fail. /* prototype 정의 차원 */
is_present(P, Time) :- human(P), timeseg(Time), not(is_absent(P,Time)).

is_guard_present(Time) :- is_present(G, Time), guard(G).
is_guard_absent(Time) :- timeseg(Time), not(is_guard_present(Time)).

/* 약한 화이트리스트 모델 */
is_door_opened(Time, Room) :- fail. /* 임의의 강의실이 임의의 시간에 잠겨 있거나 열려 있을 수 있으므로,
  여기서 프로토타입 정의하고 뒤에서 따로 정의 */

/* X가 예약을 했으면 X는 점유할 권한이 있다. */
may_occupy(X, Time, Room) :- normal(X), timeseg(Time), room(Room), holder(X, Time, Room). /* common */
/* 경비는 존재할 때 언제나 점유할 권한이 있다. */
may_occupy(Guard, Time, Room) :- timeseg(Time), room(Room), guard(Guard), is_guard_present(Time).
/* X가 허가된 사용자면, X는 점유할 권한이 있다. */
may_occupy(X, Time, Room) :- guest(X, Time, Room). /* white list 1 */

/* 방이 열려있으면, 누구나 들어갈 수 있다. */
can_enter_1(_, Time, Room) :- is_door_opened(Time, Room). /* white list 2 */
/* 점유할 권한이 있으면, 방에 들어갈 수 있다. */
can_enter_2(A, Time, Room) :- may_occupy(A, Time, Room). /* white list 3 */
/* can_enter_1이거나 can_enter_2이고, X가 존재하면, 방에 들어갈 수 있다. */
can_enter(X, Time, Room) :- human(X), is_present(X, Time), (can_enter_1(X, Time, Room);
  can_enter_2(X, Time, Room)). /* white list 4 */

no_other_can_occupy(A, Time, Room) :- human(A), timeseg(Time), room(Room),
  not((B \= A, can_occupy(B, Time, Room))). /* white list 5 */
/* A이외의 아무도 점유할 수 없고 A가 들어갈 수 있으면 A는 점유할 수 있다. */
can_occupy(A, Time, Room) :- no_other_can_occupy(A, Time, Room), can_enter(A, Time, Room). /* white list 7 */
/* A가 B가 아니고, B가 점유할 수 있고, A가 권한이 있으면, A가 점유할 수 있다.*/
can_occupy(A, Time, Room) :- B \= A, can_occupy(B, Time, Room), may_occupy(A, Time, Room). /* white list 8 */

someone_can_occupy(Time, Room) :- timeseg(Time), room(Room), can_occupy(_, Time, Room).

noone_can_occupy(Time, Room) :- timeseg(Time), room(Room), \+ someone_can_occupy(Time, Room).

/* 아무도 점유를 할 수 없거나, 예약해놓고도 사용하지 않는 경우가 있다. */
noone_occupy(Time, Room) :- noone_can_occupy(Time, Room); (may_occupy(_, Time, Room), timeseg(Time),
  room(Room), !).

/* 문이 열려 있고 아무도 점유하고 있지 않은 상태면 파손 행위가 가능하다 */
can_harm(Time, Room) :- is_door_opened(Time, Room), noone_occupy(Time, Room).

/* 시나리오 시작 */
/* 재찬은 301호를 토요일에 이용하기로 예약했다. */
holder(jaechan, sat, r301).
/* 재찬은 301호를 일요일에 이용하기로 예약했다. */
holder(jaechan, sun, r301).
/* 슬기는 302호를 토요일에 이용하기로 예약했다. */
holder(seulgi, sat, r302).
/* 슬기는 302호를 일요일에 이용하기로 예약했다. */
holder(seulgi, sun, r302).
/* 슬기는 301호를 월요일에 이용하기로 예약했다. */
holder(seulgi, mon, r301).
/* 슬기는 301호를 화요일에 이용하기로 예약했다. */
holder(seulgi, tue, r301).
/* 수위는 토요일(특정 시각)에 자리를 비웠다. */
is_absent(g1, sat).
/* 슬기는 일요일에 학교에 오지 않았다. */
is_absent(seulgi, sun).
/* 슬기는 화요일에 학교에 오지 않았다. */
is_absent(seulgi, tue).
/* 재찬은 규민을 토요일에 301호로 초대했다. */
invite(jaechan, gyumin, sat, r301).
/* 슬기는 재찬을 토요일에 302호로 초대했다. */
invite(seulgi, jaechan, sat, r302).
/* 슬기는 규민을 일요일에 302호로 초대했다. */
invite(seulgi, gyumin, sun, r302).
/* 토요일에 302호가 열려있다. */
is_door_opened(sat, r302).
/* 시나리오 끝 */

/* 질의들. */
/* 1. 예약했고 왔는데 점유에 실패하는 경우 */
?- holder(X, Time, Room), is_present(X, Time), not(can_occupy(X, Time, Room)).
false.

/* 2. 허가되지 않은 사용자가 강의실을 점유할 수 있는가? */
?- can_occupy(A,B,C), not(may_occupy(A,B,C)).
A = gyumin,
B = sat,
C = r302 ;
A = jaesung,
B = sat,
C = r302 ;
A = chanmin,
B = sat,
C = r302 ;
false.

/* 3. can_harm(Time, Room)? */
?- can_harm(Time, Room).
Time = sat,
Room = r302.

/* 4. 경비가 없고 휴일일 때 권한 있는 사람이 점유할 수 있는가? */
?- is_guard_absent(Time), can_occupy(A, Time, Room), may_occupy(A, Time, Room), holiday(Time).
Time = sat,
A = jaechan,
Room = r301 ;
Time = sat,
A = jaechan,
Room = r302 ;
Time = sat,
A = jaechan,
Room = r302 ;
Time = sat,
A = gyumin,
Room = r301 ;
Time = sat,
A = seulgi,
Room = r302 ;
Time = sat,
A = seulgi,
Room = r302 ;
false.

/* 5. 예약한 시간에 can_harm일 수 있는가? (전원이 자리를 비우면 안되는가?) */
?- holder(A, Time, Room), can_harm(Time, Room).
A = seulgi,
Time = sat,
Room = r302 ;
false.

/* 6. 허가된 사용자가 점유할 수 없는 경우가 있는가? */
?- guest(A, Time, Room), not(can_occupy(A, Time, Room)).
false.

