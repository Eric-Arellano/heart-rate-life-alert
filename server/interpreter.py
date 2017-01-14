from response import trigger_response

OVERDOSE_HEART_RATE = 120


def interpret_heart_rate(heart_rate):
    if is_overdose(heart_rate):
        trigger_response
    else:
        pass


def is_overdose(heart_rate):
    if heart_rate == OVERDOSE_HEART_RATE:
        return True
    else:
        return False