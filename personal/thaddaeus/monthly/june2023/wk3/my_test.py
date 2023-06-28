from astroquery.sdss import SDSS
from astropy.coordinates import SkyCoord
import astropy.units as u

ra = 47.3725449025
dec = 0.8206205532
coord = SkyCoord(ra=ra*u.deg, dec=dec*u.deg)