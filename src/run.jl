function runS(stream::Stream, model)
    fit_result, _, _ = fit(model, 0, stream.samples[1:stream.n_avaiable_labels, :], stream.labels[1:stream.n_avaiable_labels, :])

    return updatePredict(model, fit_result, stream.samples[stream.n_avaiable_labels+1:end, :])
end

function runS(stream::Stream, model, interval)
    fit_result, _, _ = fit(model, 0, stream.samples[1:stream.n_avaiable_labels, :], stream.labels[1:stream.n_avaiable_labels, :])
    return updatePredict(model, fit_result, stream.samples[interval[1]:interval[2], :])
end

function runMD(stream::Stream, model)
    machine = @suppress_err MLJBase.machine(model, stream.samples, stream.labels)
    @suppress_err MLJBase.fit!(machine, rows=1:stream.n_avaiable_labels)
    return MLJBase.predict(machine, rows=stream.n_avaiable_labels+1:length(stream.labels))
end

function runMD(stream::Stream, model, interval)
    machine = @suppress_err MLJBase.machine(model, stream.samples, stream.labels)
    @suppress_err MLJBase.fit!(machine, rows=1:stream.n_avaiable_labels)
    return MLJBase.predict(machine, rows=interval[1]:interval[2])
end

function runMP(stream::Stream, model)
    machine = @suppress_err MLJBase.machine(model, stream.samples, stream.labels)
    @suppress_err MLJBase.fit!(machine, rows=1:stream.n_avaiable_labels)
    return MLJBase.predict_mode(machine, rows=stream.n_avaiable_labels+1:length(stream.labels))
end

function runMP(stream::Stream, model, interval)
    machine = @suppress_err MLJBase.machine(model, stream.samples, stream.labels)
    @suppress_err MLJBase.fit!(machine, rows=1:stream.n_avaiable_labels)
    return MLJBase.predict_mode(machine, rows=interval[1]:interval[2])
end
