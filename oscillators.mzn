% This is a general solver for n-period square oscillators of any given size
% Shiying Zheng, Katherine Chan, Cecilia Xu, Zhou Zhou
% Optimization Oberlin College Fall 2015

% Note: this program allows you to combine different constraints and objective functions.
% To avoid conflicting constraints, we have commented out the constraints and objective functions.
% Simply uncomment the constraints/objective function you would like (highlight and then press ctrl-/ or cmd-/) , and run the model!



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% When changing size of the oscillator, don't make it too small.
% For example, smallest period 2 oscillator has length 3.
% Smallest length to give feasible solution for period 3 is length 4,
% whereas smallest horizontal and verticle feasible solution for period 3 has length 9.
int: length = 10;

% number of periods
int: periods = 3;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

array[0..periods - 1, 0..length + 1, 0..length + 1] of var 0..1: patterns;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Rules of Game of life
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% compares the number of alive neighbors around (i,j) at a given period with a given number 'alive'
% return true of two numbers match
predicate sum_alive_neighbors(array[int, int, int] of var int: patterns, int: period, int: i, int: j, int: length, int: alive) = 
  alive == sum (x in max(i - 1, 0)..min(i + 1, length + 1), y in max(j - 1, 0)..min(j + 1, length + 1)) (patterns[period, x, y])
    - patterns[period, i, j];

% live constraints
constraint forall(period in 0..periods - 1) (
  forall(i,j in 0..length + 1) (
    sum_alive_neighbors(patterns, period, i, j, length, 3)
      -> patterns[(period + 1) mod periods, i, j] = 1
  )
);

% stay the same constraints
constraint forall(period in 0..periods - 1) (
  forall(i,j in 0..length + 1) (
    sum_alive_neighbors(patterns, period, i, j, length, 2)
      -> patterns[(period + 1) mod periods, i, j] = patterns[period, i, j]
  )
);

% die constraints
constraint forall(period in 0..periods - 1) (
  forall(i,j in 0..length + 1) (
    (sum_alive_neighbors(patterns, period, i, j, length, 2) == false) /\ (sum_alive_neighbors(patterns, period, i, j, length, 3) == false)
      -> patterns[(period + 1) mod periods, i, j] = 0
  )
);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Symmetry constraints
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% horizontal symmetry constraints
%constraint forall(period in 0..periods - 1) (
%  forall(i in 0..(length + 1) div 2, j in 0..length + 1) (
%    patterns[period, i, j] == patterns[period, length - i + 1, j]
%  )
%);

% vertical symmetry constraints
%constraint forall(period in 0..periods - 1) (
%  forall(i in 0..length + 1, j in 0..(length + 1) div 2) (
%    patterns[period, i, j] == patterns[period, i, length - j + 1]
%  )
%);

% diagonal symmetry constraints
%constraint forall(period in 0..periods - 1) (
%  forall(i in 0..(length + 1), j in 0..i) (
%    patterns[period, i, j] == patterns[period, j, i]
%  )
%);

% the other diagonal symmetry constraints
%constraint forall(period in 0..periods - 1) (
%  forall(j in 0..(length + 1), i in 0..j) (
%    patterns[period, i, j] == patterns[period, length - j + 1, length - i + 1]
%  )
%);

% 90 degree rotational symmetry, clockwise
constraint forall(period in 0..periods - 1) (
  forall(j in 0..(length + 1), i in 0..(length + 1)) (
    patterns[period, i, j] == patterns[period, j, length - i + 1]
  )
);

% 90 degree rotational symmetry, counter-clockwise
%constraint forall(period in 0..periods - 1) (
%  forall(j in 0..(length + 1), i in 0..(length + 1)) (
%    patterns[period, i, j] == patterns[period, length - j + 1, i]
%  )
%);

% 180 degree rotational symmetry
%constraint forall(period in 0..periods - 1) (
%  forall(i in 0..length + 1, j in 0..length + 1) (
%    patterns[period, i, j] == patterns[period, length - i + 1, length - j + 1]
%  )
%);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Brightness change constraints
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% decreasing brightness (increasing intensity)
constraint forall(period in 0..periods - 2) (
  sum (i in 0..length+1, j in 0..length+1) (patterns[period + 1, i, j]) > sum (i in 0..length+1, j in 0..length+1) (patterns[period, i, j])
);

% increasing brightness (decreasing intensity)
%constraint forall(period in 0..periods - 2) (
%  sum (i in 0..length+1, j in 0..length+1) (patterns[period + 1, i, j]) < sum (i in 0..length+1, j in 0..length+1) (patterns[period, i, j])
%);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Avoid still life constraints
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% can't have the same pattern in every period
constraint (sum (period in 0..periods - 1, i in 0..length+1, j in 0..length+1) (patterns[(period + 1) mod periods, i, j] != patterns[period, i, j])) != 0;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Border must be empty constraints
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
constraint forall(period in 0..periods - 1) (
  forall(j in 0..length + 1, i in 0..length + 1) (
    if i == 0 \/ i == length + 1 then
      patterns[period, i, j] == 0
    elseif j == 0 \/ j == length + 1 then
      patterns[period, i, j] == 0
    else
      true
    endif
  )
);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Objectives
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% find a feasible solution, no objective function
%solve satisfy;

% find max average density solution
%solve maximize sum(period in 0..periods - 1, i in 0..length+1, j in 0..length+1) (patterns[period, i, j]);

% find solution that maximizes the difference between any two periods%constraint patterns[1, 0, 1] != patterns[0, 0, 1];
%solve maximize sum(i in 0..length+1, j in 0..length+1) (patterns[1, i, j] != patterns[0, i, j]);

% find solution that maximizes the difference between the first and the last periods. 
% this is actually the same as the previous objective when there are no restrictions on increasing or decreasing density.
solve maximize sum(i in 0..length+1, j in 0..length+1) (patterns[periods - 1, i, j] != patterns[0, i, j]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Output to MiniZinc Console
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

output
[
  if i == 0 /\ j==0 then
  "period " ++ show(period) ++ "\n" ++ show(patterns[period,i,j]) ++ " "
  elseif j == length + 1 then
  show(patterns[period,i,j]) ++ "\n"
  else
  show(patterns[period,i,j]) ++ " "
  endif
  | period in 0..periods-1, i in 0..length+1, j in 0..length+1
];