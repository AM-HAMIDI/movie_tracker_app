const validateRegistration = (req, res, next) => {
  const { fullName, username, email, password } = req.body;

  if (!fullName || !username || !email || !password) {
    return res.status(400).json({
      statusCode: 400,
      errorMessage: 'Full name, username, email, and password are required fields.',
    });
  }

  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    return res.status(400).json({
      statusCode: 400,
      errorMessage: 'Invalid email address format.',
    });
  }

  if (password.length < 6) {
    return res.status(400).json({
      statusCode: 400,
      errorMessage: 'Password must be at least 6 characters long.',
    });
  }

  next();
};

const validateRating = (req, res, next) => {
  const { rating } = req.body;
  if (rating !== undefined && (rating < 0 || rating > 5)) {
    return res.status(400).json({
      statusCode: 400,
      errorMessage: 'Rating must be an integer between 0 and 5 stars.',
    });
  }
  next();
};

module.exports = { validateRegistration, validateRating };