# Here we are using the same logic of the MLJ Library, but there is a function
#added to data streams context, such function, updatePredict, which execute
#the prediction and the update routine of the model using the instance(s) predicted.


# fit(model, verb::Integer, training_args...) -> fitresult, cache, report`
function fit end


# predict(model, fitresult, instance) -> label_predicted`
function predict end


# predict(model, fitresult, instance) -> label_predicted`
function updatePredict end
