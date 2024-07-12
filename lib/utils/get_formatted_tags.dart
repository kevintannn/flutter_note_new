List<String> getFormattedTags(String tags) {
  return tags.split(',').map((tag) => tag.trim()).toList();
}
