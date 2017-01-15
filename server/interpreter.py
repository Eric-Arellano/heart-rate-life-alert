OVERDOSE_HEART_RATE = 180
FAKE_KILL = -1


def is_overdose(heart_rate):
    if heart_rate >= OVERDOSE_HEART_RATE:
        return True
    else:
        return False


def is_fake_kill(heart_rate):
    if heart_rate >= OVERDOSE_HEART_RATE:
        return True
    else:
        return False
