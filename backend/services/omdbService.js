const axios = require('axios');
const MediaCache = require('../models/MediaCache');

const OMDB_BASE_URL = 'http://www.omdbapi.com/';
const API_KEY = process.env.OMDB_API_KEY;

const searchMedia = async (query) => {
  try {
    const response = await axios.get(OMDB_BASE_URL, {
      params: { s: query, apikey: API_KEY },
      timeout: 8000,
    });

    if (response.data.Response === 'False') {
      return [];
    }

    return response.data.Search.map((item) => ({
      imdbId: item.imdbID,
      title: item.Title,
      year: item.Year,
      type: item.Type === 'series' ? 'series' : 'movie',
      poster: item.Poster !== 'N/A' ? item.Poster : '',
    }));
  } catch (error) {
    // If IMDb API fails or is unreachable, attempt local DB search
    const regex = new RegExp(query, 'i');
    const localItems = await MediaCache.find({ title: regex }).limit(20);
    return localItems.map((item) => ({
      imdbId: item.imdbId,
      title: item.title,
      year: item.year,
      type: item.type,
      poster: item.poster,
    }));
  }
};

const getMediaDetails = async (imdbId) => {
  // 1. Cache-First check
  let cached = await MediaCache.findOne({ imdbId });
  if (cached) {
    return cached;
  }

  // 2. Query external IMDb/OMDb
  try {
    const response = await axios.get(OMDB_BASE_URL, {
      params: { i: imdbId, plot: 'full', apikey: API_KEY },
      timeout: 8000,
    });

    if (response.data.Response === 'False') {
      const err = new Error(response.data.Error || 'Media item not found on IMDb.');
      err.status = 404;
      throw err;
    }

    const data = response.data;
    const newMedia = new MediaCache({
      imdbId: data.imdbID,
      title: data.Title,
      type: data.Type === 'series' ? 'series' : 'movie',
      poster: data.Poster !== 'N/A' ? data.Poster : '',
      plot: data.Plot !== 'N/A' ? data.Plot : 'No plot overview available.',
      genre: data.Genre !== 'N/A' ? data.Genre : 'N/A',
      year: data.Year !== 'N/A' ? data.Year : 'N/A',
      runtime: data.Runtime !== 'N/A' ? data.Runtime : 'N/A',
      director: data.Director !== 'N/A' ? data.Director : 'N/A',
      actors: data.Actors !== 'N/A' ? data.Actors : 'N/A',
      imdbRating: data.imdbRating !== 'N/A' ? data.imdbRating : 'N/A',
      totalSeasons: parseInt(data.totalSeasons, 10) || 0,
      seasons: {},
    });

    await newMedia.save();
    return newMedia;
  } catch (error) {
    if (error.status === 404) throw error;
    throw new Error('Failed to retrieve media metadata from external service.');
  }
};

const getSeasonDetails = async (imdbId, seasonNumber) => {
  let media = await MediaCache.findOne({ imdbId });
  if (!media) {
    media = await getMediaDetails(imdbId);
  }

  const seasonKey = seasonNumber.toString();
  if (media.seasons && media.seasons.get(seasonKey)) {
    return media.seasons.get(seasonKey);
  }

  try {
    const response = await axios.get(OMDB_BASE_URL, {
      params: { i: imdbId, Season: seasonNumber, apikey: API_KEY },
      timeout: 8000,
    });

    if (response.data.Response === 'False' || !response.data.Episodes) {
      return [];
    }

    const episodes = response.data.Episodes.map((ep) => ({
      episodeNumber: parseInt(ep.Episode, 10),
      title: ep.Title,
      released: ep.Released,
      rating: ep.imdbRating !== 'N/A' ? ep.imdbRating : 'N/A',
    }));

    if (!media.seasons) media.seasons = new Map();
    media.seasons.set(seasonKey, episodes);
    await media.save();

    return episodes;
  } catch (error) {
    return [];
  }
};

module.exports = { searchMedia, getMediaDetails, getSeasonDetails };