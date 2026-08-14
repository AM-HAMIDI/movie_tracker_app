const mongoose = require('mongoose');

const MediaCacheSchema = new mongoose.Schema(
  {
    imdbId: { type: String, required: true, unique: true, index: true },
    title: { type: String, required: true },
    type: { type: String, enum: ['movie', 'series'], default: 'movie' },
    poster: { type: String, default: '' },
    plot: { type: String, default: '' },
    genre: { type: String, default: 'N/A' },
    year: { type: String, default: 'N/A' },
    runtime: { type: String, default: 'N/A' },
    director: { type: String, default: 'N/A' },
    actors: { type: String, default: 'N/A' },
    imdbRating: { type: String, default: 'N/A' },
    totalSeasons: { type: Number, default: 0 },
    seasons: {
      type: Map,
      of: [
        {
          episodeNumber: Number,
          title: String,
          released: String,
          rating: String,
        },
      ],
      default: {},
    },
    cachedAt: { type: Date, default: Date.now },
  },
  { timestamps: true }
);

module.exports = mongoose.model('MediaCache', MediaCacheSchema);