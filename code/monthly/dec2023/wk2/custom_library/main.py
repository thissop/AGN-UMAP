from scipy.optimize import least_squares
import numpy as np

def fit_continuum(wave, flux): 

    # from 

    # windows to fit continuum in
    continuum_windows = np.array(
                        [(1150., 1170.), (1275., 1290.),  (1350., 1360.),  (1445., 1465.),
                        (1690., 1705.),  (1770., 1810.),  (1970., 2400.),  (2480., 2675.),
                        (2925., 3400.),  (3775., 3832.),  (4000., 4050.),  (4200., 4230.),
                        (4435., 4640.),  (5100., 5535.),  (6005., 6035.),  (6110., 6250.),
                        (6800., 7000.),  (7160., 7180.),  (7500., 7800.),  (8050., 8150.)])


    x = np.linspace(1000,10000, 10000)
    masked = x
    for window in continuum_windows:
        masked = np.ma.masked_where((x > window[0]) & (x < window[1]), masked)

    mask = np.ma.getmask(masked) 
    wave, flux = wave[mask], flux[mask]

    '''
    # continuum model fit parameters
    Fe_uv_op=True, 
    poly=True, 
    BC=False, 
    initial_guess=None,  
    rej_abs_conti=False, 
    n_pix_min_conti=100, 
    '''

    # parameters for continuum priors
    # 'parname, initial,   min,     max,     vary'
    conti_priors = np.rec.array([
        ('Fe_uv_norm',  0.0,   0.0,   1e10,  1), # Normalization of the MgII Fe template [flux]
        ('Fe_uv_FWHM',  3000,  1200,  18000, 1), # FWHM of the MgII Fe template [AA]
        ('Fe_uv_shift', 0.0,   -0.01, 0.01,  1), # Wavelength shift of the MgII Fe template [lnlambda]
        ('Fe_op_norm',  0.0,   0.0,   1e10,  1), # Normalization of the Hbeta/Halpha Fe template [flux]
        ('Fe_op_FWHM',  3000,  1200,  18000, 1), # FWHM of the Hbeta/Halpha Fe template [AA]
        ('Fe_op_shift', 0.0,   -0.01, 0.01,  1), # Wavelength shift of the Hbeta/Halpha Fe template [lnlambda]
        ('PL_norm',     1.0,   0.0,   1e10,  1), # Normalization of the power-law (PL) continuum f_lambda = (lambda/3000)^-alpha
        ('PL_slope',    -1.5,  -5.0,  3.0,   1), # Slope of the power-law (PL) continuum
        ('Blamer_norm', 0.0,   0.0,   1e10,  1), # Normalization of the Balmer continuum at < 3646 AA [flux] (Dietrich et al. 2002)
        ('Balmer_Te',   15000, 10000, 50000, 1), # Te of the Balmer continuum at < 3646 AA [K?]
        ('Balmer_Tau',  0.5,   0.1,   2.0,   1), # Tau of the Balmer continuum at < 3646 AA
        ('conti_a_0',   0.0,   None,  None,  1), # 1st coefficient of the polynomial continuum
        ('conti_a_1',   0.0,   None,  None,  1), # 2nd coefficient of the polynomial continuum
        ('conti_a_2',   0.0,   None,  None,  1), # 3rd coefficient of the polynomial continuum
        # Note: The min/max bounds on the conti_a_0 coefficients are ignored by the code,
        # so they can be determined automatically for numerical stability.
        ])

def deredden(wave, flux, z): 
    wave = wave / (1 + z)
    flux = flux * (1 + z)
    #err = err * (1 + z)
    #self.fwhm = self.fwhm / (1 + self.z)

    return wave, flux#, err

def fit(wave, flux):
    from scipy.optimize import least_squares

    model = None 
    initial_values = None 
    bounds = None 

    solutions = least_squares(fun=model, x0=initial_values,
                              method='lm', bounds=bounds)
    





# how do we ensure that there isn't bias in the wavelength ranges that have data? 
# fit continuum and 18 lines? follow pyqsofit and fantasy? 