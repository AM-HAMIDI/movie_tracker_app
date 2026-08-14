const mongoose = require('mongoose');

const CommentSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    imdbId: { type: String, required: true, index: true },
    text: { type: String, required: true, trim: true },
    hasSpoiler: { type: Boolean, default: false },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Comment', CommentSchema);