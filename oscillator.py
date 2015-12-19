from Numberjack import *


def get_neighbors(patterns, length, i, x, y):
    left_x = max(x-1, 0)
    right_x = min(x+1, length-1)
    top_y = max(y-1, 0)
    bottom_y = min(y+1, length-1)

    neighbors = []

    for k in range(left_x, right_x + 1):
        for l in range(top_y, bottom_y + 1):
            if not (k == x and l == y):
                neighbors.append(patterns[i][k][l])

    return neighbors


def model_oscillator(length, periods, objective_options, all_diff):
    #patterns = [Matrix(length, length, 0, 1)]*periods
    patterns = []
    for i in range(periods):
        patterns.append(Matrix(length, length, 0, 1, 'x[' + str(i) + ']'))

    model = Model(
        # live
        [(Sum(get_neighbors(patterns, length, i, x, y)) == 3)
          >= (patterns[(i + 1) % periods][x][y] == 1)
         for i in range(periods)
         for x in range(length)
         for y in range(length)],

        # stay the same
        [(Sum(get_neighbors(patterns, length, i, x, y)) == 2)
          >= (patterns[(i + 1) % periods][x][y] == patterns[i][x][y])
         for i in range(periods)
         for x in range(length)
         for y in range(length)],

        # die
        [((Sum(get_neighbors(patterns, length, i, x, y)) < 2)
           | (Sum(get_neighbors(patterns, length, i, x, y)) > 3))
          >= (patterns[(i + 1) % periods][x][y] == 0)
         for i in range(periods)
         for x in range(length)
         for y in range(length)]
        )
    """
    model.add(
        (Sum([patterns[(i + 1) % periods][x][y] - patterns[i][x][y]
             for i in range(periods)
             for x in range(length)
             for y in range(length)])) != 0
        )
    """
    # add objective
    #if objective_option == 'max difference between period 1 and 2':
    #    diff = Sum(5)
    #    model.add(Maximise(diff))

    model.add(Maximise(Sum([patterns[1][x][y] - patterns[0][x][y]
                        for x in range(length)
                        for y in range(length)])))

    return (patterns, model)


def solve_oscillator(length=10,
                     periods=3,
                     objective_option=None,
                     all_diff=False,
                     solver='Mistral'):
    (patterns,model) = model_oscillator(length,
                                        periods,
                                        objective_option,
                                        all_diff)
    print model.constraints
    solver = model.load(solver)
    solver.solve()
    print_oscillator(patterns, solver)
    print 'Nodes:', solver.getNodes(), ' Time:', solver.getTime()


def print_oscillator(oscillator, solver):
    for oscillator in oscillator:
        for row in oscillator:
            line = ""
            for var in row:
                print var.get_value()
                if var.get_value() == True:
                    line += "*"
                else:
                    line += "-"
            print line
        print


# should be able to handle command line args
solve_oscillator(5, 2, None, False, "SCIP")
