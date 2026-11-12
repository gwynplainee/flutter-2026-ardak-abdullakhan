# Notes
## Level 1
- Constructors touched for `total`: <N> (files: ...)
- Console lines after one Add tap: <N>
## Level 3: provider errors
- Loud (watch in onPressed): "Tried to listen to a value exposed with provider, from outside of the widget tree..."
- Silent (read in build): no error, badge stuck at 0
## Level 4: rebuilds (3 presses of +)
- Badge with watch: 3
- Badge with select: 0
## Where does it live?
- **The cart**: provided. The badge, the Books screen and the Cart screen
  (different routes) all need it, so it sits above MaterialApp.
- **Search text**: ephemeral. Only the search field and the list filter
  use it, both inside one widget's State.
- **Total expanded/collapsed**: ephemeral. Pure presentation of one widget;
  nobody else cares, and it can reset when the screen closes.
- **Theme mode**: provided. MaterialApp (the root) reads it, and a switch
  elsewhere writes it, so it must sit above both.