ARG TF_IMAGE=tensorflow/tensorflow:1.15.0-py3
FROM $TF_IMAGE

COPY tf.py /app/tf.py
