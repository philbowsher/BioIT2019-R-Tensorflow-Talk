# https://github.com/snowde/interpretable-ml-book9/blob/f687173ddb765de2c38a656360c5d9e1e8ecfa95/temp_scripts/imagenet_classifier.R
# https://github.com/jasdumas/image-clf-keras-shiny/blob/50ef07e63d9833727efd177ff35fc6e858f84a35/resnet50_example.R
# https://cran.rstudio.com/web/packages/keras/vignettes/applications.html



Sys.setenv(TENSORFLOW_PYTHON="~/.virtualenvs/r-tensorflow/bin/python")
library(keras)

use_implementation("keras")

model <- application_resnet50(weights = 'imagenet')

# load the image (copy an image from Photos)
img_path <- "butterfly2.jpg"
img <- image_load(img_path, target_size = c(224,224))
x <- image_to_array(img)

# ensure we have a 4d tensor with single element in the batch dimension,
# the preprocess the input for prediction using resnet50
x <- array_reshape(x, c(1, dim(x)))
x <- imagenet_preprocess_input(x)

# make predictions then decode and print them
preds <- model %>% predict(x)
imagenet_decode_predictions(preds, top = 3)[[1]]






# Other Example not Use

model <- application_mobilenet(weights =  'imagenet')
#model <- application_resnet50(weights = 'imagenet')

# load the image
# img_path <- "F:/Data/pets_data/cats/20160211_200107000_iOS.jpg"
#img_path <- "F:/Data/pets_data/dogs/IMG_20170920_200039_286.jpg"
img_path <- "download.jpg"
img <- image_load(img_path, target_size = c(224,224))
x <- image_to_array(img)

# ensure we have a 4d tensor with single element in the batch dimension,
# the preprocess the input for prediction using resnet50
x <- array_reshape(x, c(1, dim(x)))
x <- imagenet_preprocess_input(x)

# make predictions then decode and print them
preds <- model %>% predict(x)
imagenet_decode_predictions(preds, top = 3)[[1]]

library(lime)
library(abind)

img_preprocess <- function(x) {
  arrays <- lapply(x, function(path) {
    img <- image_load(path, target_size = c(224,224))
    x <- image_to_array(img)
    x <- array_reshape(x, c(1, dim(x)))
    x <- imagenet_preprocess_input(x)
  })
  do.call(abind, c(arrays, list(along = 1)))
}

# Create an explainer (lime recognise the path as an image)
explainer <- lime(img_path, as_classifier(model), img_preprocess)


# Explain the model (can take a long time depending on your system)
explanation <- explain(img_path, explainer, n_labels = 2, n_features = 3, n_superpixels = 10)

library(microbenchmark)
mb <- microbenchmark(
  explanation1 <- explain(img_path, explainer, n_labels = 2, n_features = 3, n_superpixels = 10),
  explanation2 <- explain(img_path, explainer, n_labels = 1, n_features = 3, n_superpixels = 10),
  explanation3 <- explain(img_path, explainer, n_labels = 2, n_features = 10, n_superpixels = 10),
  explanation4 <- explain(img_path, explainer, n_labels = 2, n_features = 3, n_superpixels = 20)
)
# explanation$label <- imagenet_decode_predictions(explanation$label_prob)

plot_explanations(explanation1)