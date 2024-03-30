import tensorflow as tf
import keras
from keras import layers

input_vector = keras.Input(shape=(4600))

encoded = layers.Conv1D(filters=128, kernel_size=5, activation='relu')(input_vector)
encoded = layers.MaxPool1D(s=5, padding=5//2)(encoded)

encoded = layers.Conv1D(filters=256, kernel_size=11, activation='relu')(encoded)
encoded = layers.MaxPool1D(s=11, padding = 11//2)(encoded)

encoded = layers.Conv1D(filters=512, kernel_size=21, activation='relu')(encoded)
encoded = layers.MaxPool1D(s=21, padding=21//2)(encoded)

encoded = layers.Dense(64, activation='relu')(encoded)
encoded = layers.Dense(32, activation='relu')(encoded)

decoded = layers.Dense(64, activation='relu')(encoded)
decoded = layers.Dense(128, activation='relu')(decoded)
decoded = layers.Dense(784, activation='sigmoid')(decoded)