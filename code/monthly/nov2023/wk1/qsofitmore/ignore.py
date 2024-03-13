import numpy as np
from scipy.interpolate import UnivariateSpline
import matplotlib.pyplot as plt

# Sample data
x = np.array([1, 2, 3, 4, 5])
y = np.array([2, 1, 4, 3, 5])

# Create a smoothing spline interpolation
spline = UnivariateSpline(x, y, s=0.1)  # Adjust the smoothing factor 's' as needed

# Define new x values over a given range
x_new = np.linspace(1.5, 2.5, 20)  # Adjust the range and number of points as needed

# Evaluate the smoothing spline at the new x values
y_new = spline(x_new)

# Plot the original points and the smoothing spline
plt.scatter(x, y, label='Original Points')
plt.plot(x_new, y_new, label='Smoothing Spline', color='red')
plt.legend()
plt.xlabel('x')
plt.ylabel('y')
plt.title('Smoothing Spline Interpolation')
plt.show()
