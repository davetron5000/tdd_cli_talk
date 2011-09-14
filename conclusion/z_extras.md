!SLIDE bullets
# Mock filesystem?
# `MockFS`
* Requires rewrite
* No affect on other code that uses `File`, etc.

!SLIDE bullets
# Mock filesystem?
## `FakeFS`
* Not every method supported
* Requires our code to do `FileUtils.mkdir_p`

