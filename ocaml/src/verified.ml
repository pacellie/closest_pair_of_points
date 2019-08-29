type 'a one = {one : 'a};;
let one _A = _A.one;;

let one_real = ({one = 1.0} : float one);;

type 'a times = {times : 'a -> 'a -> 'a};;
let times _A = _A.times;;

type 'a power = {one_power : 'a one; times_power : 'a times};;

let times_real = ({times = Pervasives.( *. )} : float times);;

let power_real =
  ({one_power = one_real; times_power = times_real} : float power);;

type 'a ord = {less_eq : 'a -> 'a -> bool; less : 'a -> 'a -> bool};;
let less_eq _A = _A.less_eq;;
let less _A = _A.less;;

let ord_real =
  ({less_eq = Pervasives.(<=); less = Pervasives.(<)} : float ord);;

type 'a preorder = {ord_preorder : 'a ord};;

type 'a order = {preorder_order : 'a preorder};;

let preorder_real = ({ord_preorder = ord_real} : float preorder);;

let order_real = ({preorder_order = preorder_real} : float order);;

type 'a linorder = {order_linorder : 'a order};;

let linorder_real = ({order_linorder = order_real} : float linorder);;

let ord_integer = ({less_eq = Z.leq; less = Z.lt} : Z.t ord);;

type nat = Nat of Z.t;;

type num = One | Bit0 of num | Bit1 of num;;

let rec integer_of_nat (Nat x) = x;;

let rec max _A a b = (if less_eq _A a b then b else a);;

let rec minus_nat
  m n = Nat (max ord_integer Z.zero
              (Z.sub (integer_of_nat m) (integer_of_nat n)));;

let rec equal_nat m n = Z.equal (integer_of_nat m) (integer_of_nat n);;

let zero_nat : nat = Nat Z.zero;;

let one_nat : nat = Nat (Z.of_int 1);;

let rec take
  n x1 = match n, x1 with n, [] -> []
    | n, x :: xs ->
        (if equal_nat n zero_nat then []
          else x :: take (minus_nat n one_nat) xs);;

let rec hd (x21 :: x22) = x21;;

let rec apsnd f (x, y) = (x, f y);;

let divmod_integer
  k l = (if Z.equal k Z.zero then (Z.zero, Z.zero)
          else (if Z.lt Z.zero l
                 then (if Z.lt Z.zero k
                        then (fun k l -> if Z.equal Z.zero l then
                               (Z.zero, l) else Z.div_rem (Z.abs k) (Z.abs l))
                               k l
                        else (let (r, s) =
                                (fun k l -> if Z.equal Z.zero l then
                                  (Z.zero, l) else Z.div_rem (Z.abs k)
                                  (Z.abs l))
                                  k l
                                in
                               (if Z.equal s Z.zero then (Z.neg r, Z.zero)
                                 else (Z.sub (Z.neg r) (Z.of_int 1),
Z.sub l s))))
                 else (if Z.equal l Z.zero then (Z.zero, k)
                        else apsnd Z.neg
                               (if Z.lt k Z.zero
                                 then (fun k l -> if Z.equal Z.zero l then
(Z.zero, l) else Z.div_rem (Z.abs k) (Z.abs l))
k l
                                 else (let (r, s) =
 (fun k l -> if Z.equal Z.zero l then (Z.zero, l) else Z.div_rem (Z.abs k)
   (Z.abs l))
   k l
 in
(if Z.equal s Z.zero then (Z.neg r, Z.zero)
  else (Z.sub (Z.neg r) (Z.of_int 1), Z.sub (Z.neg l) s)))))));;

let rec fst (x1, x2) = x1;;

let rec divide_integer k l = fst (divmod_integer k l);;

let rec divide_nat
  m n = Nat (divide_integer (integer_of_nat m) (integer_of_nat n));;

let rec rev_it_rec acc x1 = match acc, x1 with acc, [] -> acc
                     | acc, x :: xs -> rev_it_rec (x :: acc) xs;;

let rec rev_it xs = rev_it_rec [] xs;;

let rec split_at_it_rec
  acc n x2 = match acc, n, x2 with acc, n, [] -> (rev_it acc, [])
    | acc, n, x :: xs ->
        (if equal_nat n zero_nat then (rev_it acc, x :: xs)
          else split_at_it_rec (x :: acc) (minus_nat n one_nat) xs);;

let rec split_at_it n xs = split_at_it_rec [] n xs;;

let rec nat_of_integer k = Nat (max ord_integer Z.zero k);;

let rec plus_nat m n = Nat (Z.add (integer_of_nat m) (integer_of_nat n));;

let rec length_it_rec
  acc x1 = match acc, x1 with acc, [] -> acc
    | acc, x :: xs -> length_it_rec (plus_nat acc one_nat) xs;;

let rec length_it xs = length_it_rec zero_nat xs;;

let rec merge_it_rec _B
  f acc x2 x3 = match f, acc, x2, x3 with f, acc, [], [] -> rev_it acc
    | f, acc, x :: xs, [] -> merge_it_rec _B f (x :: acc) xs []
    | f, acc, [], y :: ys -> merge_it_rec _B f (y :: acc) ys []
    | f, acc, x :: xs, y :: ys ->
        (if less_eq _B.order_linorder.preorder_order.ord_preorder (f x) (f y)
          then merge_it_rec _B f (x :: acc) xs (y :: ys)
          else merge_it_rec _B f (y :: acc) (x :: xs) ys);;

let rec merge_it _B f xs ys = merge_it_rec _B f [] xs ys;;

let rec msort _B
  f x1 = match f, x1 with f, [] -> []
    | f, [x] -> [x]
    | f, x :: y :: xs ->
        (let xsa = x :: y :: xs in
         let n = divide_nat (length_it xsa) (nat_of_integer (Z.of_int 2)) in
         let (l, r) = split_at_it n xsa in
          merge_it _B f (msort _B f l) (msort _B f r));;

let rec sortX ps = msort linorder_real fst ps;;

let rec snd (x1, x2) = x2;;

let rec sortY ps = msort linorder_real snd ps;;

let rec power _A
  a n = (if equal_nat n zero_nat then one _A.one_power
          else times _A.times_power a (power _A a (minus_nat n one_nat)));;

let rec dist_code
  p_0 p_1 =
    Pervasives.( +. )
      (power power_real (Pervasives.( -. ) (fst p_0) (fst p_1))
        (nat_of_integer (Z.of_int 2)))
      (power power_real (Pervasives.( -. ) (snd p_0) (snd p_1))
        (nat_of_integer (Z.of_int 2)));;

let rec find_closest_it_rec
  p c_0 x2 = match p, c_0, x2 with p, c_0, [] -> c_0
    | p, c_0, c_1 :: cs ->
        (if Pervasives.(<) (dist_code p c_0) (dist_code p c_1)
          then find_closest_it_rec p c_0 cs else find_closest_it_rec p c_1 cs);;

let rec find_closest_it
  uu x1 = match uu, x1 with uu, [] -> failwith "undefined"
    | p, p_0 :: ps -> find_closest_it_rec p p_0 ps;;

let rec gen_closest_pair_it_rec
  f x1 x2 = match f, x1, x2 with f, (c_0, c_1), [] -> (c_0, c_1)
    | f, (c_0, c_1), [p_0] -> (c_0, c_1)
    | f, (c_0, c_1), p_0 :: v :: va ->
        (let p_1 = find_closest_it p_0 (f (v :: va)) in
          (if Pervasives.(<) (dist_code c_0 c_1) (dist_code p_0 p_1)
            then gen_closest_pair_it_rec f (c_0, c_1) (v :: va)
            else gen_closest_pair_it_rec f (p_0, p_1) (v :: va)));;

let rec gen_closest_pair_it
  f x1 = match f, x1 with
    f, p_0 :: p_1 :: ps ->
      gen_closest_pair_it_rec f (p_0, find_closest_it p_0 (f (p_1 :: ps)))
        (p_1 :: ps)
    | uu, [] -> failwith "undefined"
    | uu, [v] -> failwith "undefined";;

let rec bf_closest_pair_it ps = gen_closest_pair_it (fun psa -> psa) ps;;

let rec closest_pair_7_it
  ps = gen_closest_pair_it (take (nat_of_integer (Z.of_int 7))) ps;;

let rec filter_it_rec
  acc p x2 = match acc, p, x2 with acc, p, [] -> rev_it acc
    | acc, p, x :: xs ->
        (if p x then filter_it_rec (x :: acc) p xs
          else filter_it_rec acc p xs);;

let rec filter_it p xs = filter_it_rec [] p xs;;

let rec less_nat m n = Z.lt (integer_of_nat m) (integer_of_nat n);;

let rec combine_code
  (p_0_L, p_1_L) (p_0_R, p_1_R) l ys =
    (let (c_0, c_1) =
       (if Pervasives.(<) (dist_code p_0_L p_1_L) (dist_code p_0_R p_1_R)
         then (p_0_L, p_1_L) else (p_0_R, p_1_R))
       in
     let ysa =
       filter_it
         (fun p -> Pervasives.(<=) (dist_code p (l, snd p)) (dist_code c_0 c_1))
         ys
       in
      (if less_nat (length_it ysa) (nat_of_integer (Z.of_int 2)) then (c_0, c_1)
        else (let (p_0, p_1) = closest_pair_7_it ysa in
               (if Pervasives.(<) (dist_code p_0 p_1) (dist_code c_0 c_1)
                 then (p_0, p_1) else (c_0, c_1)))));;

let rec less_eq_nat m n = Z.leq (integer_of_nat m) (integer_of_nat n);;

let rec closest_pair_rec
  xs = (let n = length_it xs in
         (if less_eq_nat n (nat_of_integer (Z.of_int 3))
           then (sortY xs, bf_closest_pair_it xs)
           else (let (xs_L, xs_R) =
                   split_at_it (divide_nat n (nat_of_integer (Z.of_int 2))) xs
                   in
                 let l = fst (hd xs_R) in
                 let (ys_L, (c_0_L, c_1_L)) = closest_pair_rec xs_L in
                 let (ys_R, (c_0_R, c_1_R)) = closest_pair_rec xs_R in
                 let ys = merge_it linorder_real snd ys_L ys_R in
                  (ys, combine_code (c_0_L, c_1_L) (c_0_R, c_1_R) l ys))));;

let rec closest_pair ps = (let (_, c) = closest_pair_rec (sortX ps) in c);;