function interval(size, steps)
    _size = size
    amount = _size
    interval = Int64(floor(amount / steps))
    prequential_interval = [ interval for k in 1:steps ]
    amount -= steps * interval
    for k in 1:amount
        prequential_interval[k % steps] += 1
    end
    return prequential_interval
end
