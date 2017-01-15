OVERDOSE_HEART_RATE = 180
FAKE_KILL = -1


def is_simple_overdose(heart_rate):
    if heart_rate >= OVERDOSE_HEART_RATE:
        return True
    else:
        return False


def is_fake_kill(heart_rate):
    if heart_rate >= OVERDOSE_HEART_RATE:
        return True
    else:
        return False


def is_dynamic_overdose(heart_rates):
    vari = 0
    diff = 0
    x = 200
    if (len(heart_rates) > 19):
        for index in range(0, len(heart_rates) - 1):
            if (-1 * (len(heart_rates) - index - 18) > 0):
                diff = heart_rates[index] - (
                    .3333 * (heart_rates[index - 1] + heart_rates[index - 2] + heart_rates[index - 3]))
                vari += (-.1 * (len(heart_rates) - index - 18)) * (diff * diff)
        if (vari > x):
            return True
    return False
