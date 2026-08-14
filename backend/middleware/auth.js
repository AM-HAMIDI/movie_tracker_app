const jwt = require('jsonwebtoken');

const authenticate = (req, res, next) => {
  const authHeader = req.header('Authorization');
  const token = authHeader && authHeader.startsWith('Bearer ') 
    ? authHeader.replace('Bearer ', '') 
    : null;

  if (!token) {
    return res.status(401).json({
      statusCode: 401,
      errorMessage: 'Access Denied. Authentication token missing.',
    });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'secret');
    req.user = decoded;
    next();
  } catch (ex) {
    res.status(401).json({
      statusCode: 401,
      errorMessage: 'Invalid or expired token. Please log in again.',
    });
  }
};

const authorizeRoles = (...roles) => {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return res.status(403).json({
        statusCode: 403,
        errorMessage: 'Access Forbidden: Insufficient administrative privileges.',
      });
    }
    next();
  };
};

module.exports = { authenticate, authorizeRoles };