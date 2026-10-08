const asyncHandler = require('express-async-handler');
const mongoose = require('mongoose');
const Comment = require('../models/Comment');
const Content = require('../models/Content');

const MAX_LENGTH = 500;

// Forma en que se le entrega cada comentario a la app
const formatComment = (c) => ({
  _id: c._id,
  text: c.text,
  createdAt: c.createdAt,
  user: c.user
    ? {
        _id: c.user._id,
        name: c.user.name,
        avatar: c.user.avatar || '',
      }
    : null,
});

// @desc    Listar comentarios de un video (del más nuevo al más viejo)
// @route   GET /api/content/:id/comments?page=1&limit=20
// @access  Public
const getComments = asyncHandler(async (req, res) => {
  const { id } = req.params;

  if (!mongoose.isValidObjectId(id)) {
    res.status(404);
    throw new Error('Contenido no encontrado');
  }

  const page = Math.max(parseInt(req.query.page) || 1, 1);
  const limit = Math.min(Math.max(parseInt(req.query.limit) || 20, 1), 50);
  const skip = (page - 1) * limit;

  const [comments, total] = await Promise.all([
    Comment.find({ content: id })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .populate('user', 'name avatar'),
    Comment.countDocuments({ content: id }),
  ]);

  res.json({
    success: true,
    count: comments.length,
    total,
    page,
    pages: Math.ceil(total / limit),
    hasMore: page * limit < total,
    data: comments.map(formatComment),
  });
});

// @desc    Crear un comentario en un video
// @route   POST /api/content/:id/comments
// @access  Private
const createComment = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const text = (req.body.text || '').toString().trim();

  if (!mongoose.isValidObjectId(id) || !(await Content.exists({ _id: id }))) {
    res.status(404);
    throw new Error('Contenido no encontrado');
  }

  if (!text) {
    res.status(400);
    throw new Error('El comentario no puede estar vacío');
  }

  if (text.length > MAX_LENGTH) {
    res.status(400);
    throw new Error(`El comentario no puede superar los ${MAX_LENGTH} caracteres`);
  }

  const comment = await Comment.create({
    content: id,
    user: req.user._id,
    text,
  });

  await comment.populate('user', 'name avatar');

  res.status(201).json({ success: true, data: formatComment(comment) });
});

// @desc    Borrar un comentario (el dueño o un admin)
// @route   DELETE /api/content/:id/comments/:commentId
// @access  Private
const deleteComment = asyncHandler(async (req, res) => {
  const { id, commentId } = req.params;

  if (!mongoose.isValidObjectId(id) || !mongoose.isValidObjectId(commentId)) {
    res.status(404);
    throw new Error('Comentario no encontrado');
  }

  const comment = await Comment.findOne({ _id: commentId, content: id });

  if (!comment) {
    res.status(404);
    throw new Error('Comentario no encontrado');
  }

  const isOwner = comment.user.toString() === req.user._id.toString();
  const isAdmin = req.user.role === 'admin';

  if (!isOwner && !isAdmin) {
    res.status(403);
    throw new Error('No puedes borrar este comentario');
  }

  await comment.deleteOne();

  res.json({ success: true, message: 'Comentario eliminado' });
});

module.exports = { getComments, createComment, deleteComment };