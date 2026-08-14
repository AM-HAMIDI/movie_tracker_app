const express = require('express');
const router = express.Router();
const omdbService = require('../services/omdbService');

/**
 * @swagger
 * /api/media/search:
 *   get:
 *     summary: Search movies and series
 *     tags: [Media]
 */
router.get('/search', async (req, res, next) => {
  try {
    const query = req.query.q;
    if (!query) {
      return res.status(400).json({
        statusCode: 400,
        errorMessage: "Search query parameter 'q' is required.",
      });
    }
    const results = await omdbService.searchMedia(query);
    res.json(results);
  } catch (err) {
    next(err);
  }
});

/**
 * @swagger
 * /api/media/detail/{imdbId}:
 *   get:
 *     summary: Get full title details
 *     tags: [Media]
 */
router.get('/detail/:imdbId', async (req, res, next) => {
  try {
    const details = await omdbService.getMediaDetails(req.params.imdbId);
    res.json(details);
  } catch (err) {
    next(err);
  }
});

/**
 * @swagger
 * /api/media/detail/{imdbId}/season/{seasonNum}:
 *   get:
 *     summary: Get episodes for a specific season
 *     tags: [Media]
 */
router.get('/detail/:imdbId/season/:seasonNum', async (req, res, next) => {
  try {
    const episodes = await omdbService.getSeasonDetails(
      req.params.imdbId,
      parseInt(req.params.seasonNum, 10)
    );
    res.json(episodes);
  } catch (err) {
    next(err);
  }
});

module.exports = router;