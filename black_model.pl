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

stronger1(jaechan,gyumin).
stronger1(gyumin,seulgi).
stronger1(seulgi,jaesung).
stronger1(jaesung,chanmin).
/* transitive */
stronger(A,B) :- stronger1(A,B); (stronger1(A,C), stronger(C,B)).

/* any combination that is not holder */
/* if X is holder of Room on Time then, X is not not holder of Room on Time. */
not_holder(X, Time, Room) :- normal(X), timeseg(Time), room(Room), \+ holder(X, Time, Room).

/* the condition that should be satisfied for invite */
/* if X invited someone, then X should be the holder of the room, otherwise fail. */
/* !, fail. 은 존재의 부정을 의미한다. 즉 앞 predicate가 true가 되면 즉시 탐색을 멈추고, false를 리턴 */
invite(X, _, Time, Room) :- not_holder(X, Time, Room), !, fail.
guest(X, Time, Room) :- holder(Y, Time, Room), invite(Y, X, Time, Room). /* common */

is_absent(P, Time) :- fail. /* prototype 정의 차원 */
is_present(P, Time) :- human(P), timeseg(Time), not(is_absent(P,Time)).

is_guard_present(Time) :- is_present(G, Time), guard(G).
is_guard_absent(Time) :- timeseg(Time), not(is_guard_present(Time)).

/* 문은 열려 있다. */
is_door_opened(Time, Room) :- timeseg(Time), room(Room).
/* X가 예약을 했으면 X는 점유할 권한이 있다. */
may_occupy(X, Time, Room) :- normal(X), timeseg(Time), room(Room), holder(X, Time, Room). /* common */
/* 경비는 언제나 점유할 권한이 있다. */
may_occupy(Guard, Time, Room) :- timeseg(Time), room(Room), guard(Guard). /* common */
/* X가 허가된 사용자면, X는 점유할 권한이 있다. */
may_occupy(X, Time, Room) :- guest(X, Time, Room).

may_not_occupy(X, Time, Room) :- human(X), timeseg(Time), room(Room), \+ may_occupy(X,Time,Room).

/* 방이 열려있으면, 누구나 들어갈 수 있다. */
can_enter(_, Time, Room) :- is_door_opened(Time, Room).

is_there_stronger(A, Time, Room) :- normal(A), timeseg(Time), room(Room),
  normal(B), is_present(B, Time), (may_occupy(B, Time, Room); stronger(B, A)), may_not_occupy(A, Time, Room).
/* 특정 강의실이 예약되지 않은 시간에는 누구도 그 강의실을 점유할 수 없다. */
cannot_occupy1(A, Time, Room) :- human(A), timeseg(Time), room(Room), \+ holder(_,Time,Room).
/* 특정 강의실이 예약된 시간에, 강의실에 들어갈 수 있고, 허가되지 않은 사용자가,
 * 허가된 사람이나 강한 사람이 점유하면 강의실을 점유할 수 없다. */
cannot_occupy2(A, Time, Room) :- holder(_,Time,Room), can_enter(A,Time,Room), is_there_stronger(A, Time, Room),
  may_not_occupy(A,Time,Room).
cannot_occupy(A, Time, Room) :- cannot_occupy1(A, Time, Room); cannot_occupy2(A, Time, Room).
/* 특정 강의실이 예약된 시간에, 강의실에 들어갈 수 있고, 허가되지 않은 사용자가,
 * 허가된 사람과 강한 사람이 점유하지 않으면 강의실을 점유할 수 있다. */
can_occupy(A, Time, Room) :- is_present(A, Time), normal(A), holder(_,Time,Room), can_enter(A,Time,Room),
  may_not_occupy(A,Time,Room),\+ is_there_stronger(A,Time,Room).
/* 특정 강의실이 예약된 시간에, 강의실에 들어갈 수 있고, 허가된 사용자가 강의실을 점유할 수 있다. */
can_occupy(A, Time, Room) :- is_present(A, Time), normal(A), holder(_,Time,Room), can_enter(A,Time,Room),
  may_occupy(A,Time,Room).

someone_can_occupy(Time, Room) :- timeseg(Time), room(Room), can_occupy(_, Time, Room).

noone_can_occupy(Time, Room) :- timeseg(Time), room(Room), \+ someone_can_occupy(Time, Room).

/* 아무도 점유를 할 수 없거나, 예약해놓고도 사용하지 않는 경우가 있다. */
noone_occupy(Time, Room) :- noone_can_occupy(Time, Room); (may_occupy(_, Time, Room), timeseg(Time), room(Room)).


/* 감시카메라가 있으므로 도둑질 및 파손행위를 할 수 없다. */
can_harm(Time, Room) :- holder(_,Time,Room), can_occupy(A,Time,Room), may_not_occupy(A,Time,Room).

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
/* 시나리오 끝 */

