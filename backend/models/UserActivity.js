const mongoose = require('mongoose');

const UserActivitySchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    imdbId: { type: String, required: true, index: true },
    watchStatus: {
      type: String,
      enum: ['Plan to Watch', 'Watching', 'Watched', 'On Hold', 'Dropped', 'Favorite', 'None'],
      default: 'None',
    },
    rating: { type: Number, min: 0, max: 5, default: 0 },
    isFavorite: { type: Boolean, default: false },
    watchedEpisodes: [{ type: String }], // e.g. ["S1E1", "S1E2"]
  },
  { timestamps: true }
);

UserActivitySchema.index({ userId: 1, imdbId: 1 }, { unique: true });

module.exports = mongoose.model('UserActivity', UserActivitySchema);