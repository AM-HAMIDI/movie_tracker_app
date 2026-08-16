const express = require('express');
const router = express.Router();
const UserActivity = require('../models/UserActivity');
const Comment = require('../models/Comment');
const CustomList = require('../models/CustomList');
const MediaCache = require('../models/MediaCache');
const { authenticate } = require('../middleware/auth');
const { validateRating } = require('../middleware/validator');

/**
 * @swagger
 * /api/activity/update:
 *   post:
 *     summary: Update watch status, rating, or watched episodes
 *     tags: [Activity]
 */
router.post('/update', authenticate, validateRating, async (req, res, next) => {
  try {
    const { imdbId, watchStatus, rating, isFavorite, watchedEpisodes } = req.body;
    if (!imdbId) {
      return res.status(400).json({ statusCode: 400, errorMessage: 'imdbId is required.' });
    }

    let activity = await UserActivity.findOne({ userId: req.user.id, imdbId });
    if (!activity) {
      activity = new UserActivity({ userId: req.user.id, imdbId });
    }

    if (watchStatus !== undefined) activity.watchStatus = watchStatus;
    if (rating !== undefined) activity.rating = rating;
    if (isFavorite !== undefined) activity.isFavorite = isFavorite;
    if (watchedEpisodes !== undefined) activity.watchedEpisodes = watchedEpisodes;

    await activity.save();
    res.json(activity);
  } catch (err) {
    next(err);
  }
});

/**
 * @swagger
 * /api/activity/comments/{imdbId}:
 *   get:
 *     summary: Get comments for a media title
 *     tags: [Comments]
 */
router.get('/comments/:imdbId', async (req, res, next) => {
  try {
    const comments = await Comment.find({ imdbId: req.params.imdbId })
      .populate('userId', 'username profilePicture')
      .sort({ createdAt: -1 });
    res.json(comments);
  } catch (err) {
    next(err);
  }
});

/**
 * @swagger
 * /api/activity/comments:
 *   post:
 *     summary: Post a review or comment
 *     tags: [Comments]
 */
router.post('/comments', authenticate, async (req, res, next) => {
  try {
    const { imdbId, text, hasSpoiler } = req.body;
    if (!imdbId || !text) {
      return res.status(400).json({ statusCode: 400, errorMessage: 'imdbId and comment text required.' });
    }

    const comment = new Comment({
      userId: req.user.id,
      imdbId,
      text,
      hasSpoiler: Boolean(hasSpoiler),
    });

    await comment.save();
    const populated = await comment.populate('userId', 'username profilePicture');
    res.status(201).json(populated);
  } catch (err) {
    next(err);
  }
});

/**
 * @swagger
 * /api/activity/lists:
 *   get:
 *     summary: Get user custom lists
 *     tags: [Custom Lists]
 */
router.get('/lists', authenticate, async (req, res, next) => {
  try {
    const lists = await CustomList.find({ userId: req.user.id });
    res.json(lists);
  } catch (err) {
    next(err);
  }
});

/**
 * @swagger
 * /api/activity/lists:
 *   post:
 *     summary: Create a custom playlist
 *     tags: [Custom Lists]
 */
router.post('/lists', authenticate, async (req, res, next) => {
  try {
    const { name } = req.body;
    if (!name) {
      return res.status(400).json({ statusCode: 400, errorMessage: 'List name is required.' });
    }
    const newList = new CustomList({ userId: req.user.id, name, items: [] });
    await newList.save();
    res.status(201).json(newList);
  } catch (err) {
    next(err);
  }
});

/**
 * @swagger
 * /api/activity/lists/{listId}:
 *   delete:
 *     summary: Delete a custom list
 *     tags: [Custom Lists]
 */
router.delete('/lists/:listId', authenticate, async (req, res, next) => {
  try {
    await CustomList.findOneAndDelete({ _id: req.params.listId, userId: req.user.id });
    res.json({ message: 'List deleted successfully.' });
  } catch (err) {
    next(err);
  }
});

/**
 * @swagger
 * /api/activity/lists/{listId}/items:
 *   post:
 *     summary: Add an IMDb ID to a custom list
 *     tags: [Custom Lists]
 */
router.post('/lists/:listId/items', authenticate, async (req, res, next) => {
  try {
    const { imdbId } = req.body;
    const list = await CustomList.findOne({ _id: req.params.listId, userId: req.user.id });
    
    if (!list) return res.status(404).json({ statusCode: 404, errorMessage: 'List not found.' });
    if (!list.items.includes(imdbId)) {
      list.items.push(imdbId);
      await list.save();
    }
    res.json(list);
  } catch (err) {
    next(err);
  }
});

/**
 * ADDED THIS ENDPOINT:
 * @swagger
 * /api/activity/lists/{listId}/items/{imdbId}:
 *   delete:
 *     summary: Remove an IMDb ID from a custom list
 *     tags: [Custom Lists]
 */
router.delete('/lists/:listId/items/:imdbId', authenticate, async (req, res, next) => {
  try {
    const list = await CustomList.findOne({ _id: req.params.listId, userId: req.user.id });
    
    if (!list) return res.status(404).json({ statusCode: 404, errorMessage: 'List not found.' });
    
    // Filter out the movie being removed
    list.items = list.items.filter(id => id !== req.params.imdbId);
    await list.save();
    
    res.json(list);
  } catch (err) {
    next(err);
  }
});

/**
 * @swagger
 * /api/activity/lists/{listId}/details:
 *   get:
 *     summary: Get full media details for items in a custom list
 *     tags: [Custom Lists]
 */
router.get('/lists/:listId/details', authenticate, async (req, res, next) => {
  try {
    const list = await CustomList.findOne({ _id: req.params.listId, userId: req.user.id });
    if (!list) return res.status(404).json({ statusCode: 404, errorMessage: 'List not found.' });

    const mediaItems = await MediaCache.find({ imdbId: { $in: list.items } });
    res.json(mediaItems);
  } catch (err) {
    next(err);
  }
});

/**
 * @swagger
 * /api/activity/user/statistics:
 *   get:
 *     summary: Compute activity statistics for the user profile
 *     tags: [Statistics]
 */
router.get('/user/statistics', authenticate, async (req, res, next) => {
  try {
    const activities = await UserActivity.find({ userId: req.user.id });

    let watchedMovies = 0;
    let watchedSeries = 0;
    let totalEpisodes = 0;
    let totalRatings = 0;
    let ratingCount = 0;
    const genreMap = {};

    for (const act of activities) {
      if (act.rating && act.rating > 0) {
        totalRatings += act.rating;
        ratingCount++;
      }
      totalEpisodes += act.watchedEpisodes.length;

      const media = await MediaCache.findOne({ imdbId: act.imdbId });
      if (media) {
        if (act.watchStatus === 'Watched') {
          if (media.type === 'movie') watchedMovies++;
          if (media.type === 'series') watchedSeries++;
        }
        if (media.genre && media.genre !== 'N/A') {
          media.genre.split(', ').forEach((g) => {
            genreMap[g] = (genreMap[g] || 0) + 1;
          });
        }
      }
    }

    const favoriteGenre = Object.keys(genreMap).reduce(
      (a, b) => (genreMap[a] > genreMap[b] ? a : b),
      'N/A'
    );
    const avgRating = ratingCount > 0 ? (totalRatings / ratingCount).toFixed(1) : 0;
    const totalWatchTimeMinutes = watchedMovies * 110 + totalEpisodes * 45;

    res.json({
      watchedMovies,
      watchedSeries,
      totalEpisodes,
      totalWatchTimeMinutes,
      favoriteGenre,
      averageRating: parseFloat(avgRating),
    });
  } catch (err) {
    next(err);
  }
});

/**
 * @swagger
 * /api/activity/user/all:
 *   get:
 *     summary: Get all activities for the logged-in user (for Watchlists)
 *     tags: [Activity]
 */
router.get('/user/all', authenticate, async (req, res, next) => {
  try {
    const activities = await UserActivity.find({ userId: req.user.id });
    
    const populatedActivities = await Promise.all(
      activities.map(async (act) => {
        const media = await MediaCache.findOne({ imdbId: act.imdbId });
        return {
          ...act.toObject(),
          media: media || null
        };
      })
    );
    
    res.json(populatedActivities);
  } catch (err) {
    next(err);
  }
});

/**
 * @swagger
 * /api/activity/{imdbId}:
 *   get:
 *     summary: Get logged user activity for specific title
 *     tags: [Activity]
 * 
 * FIX: Moved to the BOTTOM so it does not hijack literal paths like /lists or /user/all!
 */
router.get('/:imdbId', authenticate, async (req, res, next) => {
  try {
    const activity = await UserActivity.findOne({
      userId: req.user.id,
      imdbId: req.params.imdbId,
    });

    res.json(
      activity || {
        watchStatus: 'None',
        rating: 0,
        isFavorite: false,
        watchedEpisodes: [],
      }
    );
  } catch (err) {
    next(err);
  }
});

module.exports = router;