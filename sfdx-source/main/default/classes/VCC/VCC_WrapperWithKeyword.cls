public virtual class VCC_WrapperWithKeyword {
    // This can be overridden in a subclass if a translation is needed
    public virtual Map<String, String> getKeywordTranslationMap() {
        return new Map<String, String>();
    }
}
