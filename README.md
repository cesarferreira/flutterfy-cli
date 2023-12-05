# Flutter::Automation

<p align="center">
  <img src="assets/ss.png" width="100%" />
</p>

## Working


```bash
f fix
# => Automatically identifies and corrects common issues in Dart code, such as outdated syntax |

```
```bash
f bump active|inactive|draft
# => List all by 'active' | 'inactive' | 'draft'
```

```bash
f bump major
# => bumps the MAJOR build number (x.0.0+y)
f bump minor
# => bumps the MINOR build number (0.x.0+y)
f bump patch
# => bumps the PATCH build number (0.0.x+y)
f bump build
# => bumps the build number (1.0.0+y)  
```




```bash
f help
# => Show's info on which customer is being worked on right now
# 
# +----------------------+-------------------------------------------------------------------------------------------+
# | Command              | Description                                                                               |
# +----------------------+-------------------------------------------------------------------------------------------+
# | f clean              | Deep cleans the project and rebuilds it.                                                  |
# +----------------------+-------------------------------------------------------------------------------------------+
# | f fix                | Automatically identifies and corrects common issues in Dart code, such as outdated syntax |
# +----------------------+-------------------------------------------------------------------------------------------+
# | f generate swagger   | Executes a function to generate a Swagger (OpenAPI) client.                               |
# | f generate icon      | Generates the icons for the app.                                                          |
# | f generate assets    | Initiates asset generation and management. (using "flutter_launcher_icons")               |
# +----------------------+-------------------------------------------------------------------------------------------+
# | f open apple         | Opens the appstoreconnect website.                                                        |
# | f open android       | Opens the play console website.                                                           |
# +----------------------+-------------------------------------------------------------------------------------------+
# | f release beta       | Releases the current build to the beta track.                                             |
# | f release production | Releases the current build to the production track.                                       |
# +----------------------+-------------------------------------------------------------------------------------------+
# | f bump major         | bumps the MAJOR build number (x.0.0+y)                                                    |
# | f bump minor         | bumps the MINOR build number (0.x.0+y)                                                    |
# | f bump patch         | bumps the PATCH build number (0.0.x+y)                                                    |
# | f bump build         | bumps the build number (1.0.0+y)                                                          |
# +----------------------+-------------------------------------------------------------------------------------------+
# | f help               | Shows a table with all the available commands.                                            |
# +----------------------+-------------------------------------------------------------------------------------------+

```


## Nice to Have
- [ ] be able to list all the actions with some `f actions`